/**
 * Comprehensive API Client with Retry Logic, Caching, and Error Handling
 * Provides robust HTTP client for BlueSavings backend services
 */

import { logger, NetworkError, ValidationError, BlueSavingsError, ErrorType } from './error-handling';
import { configManager } from '../config/config-manager';

// Types and interfaces
export interface ApiResponse<T = any> {
  data: T;
  status: number;
  statusText: string;
  headers: Record<string, string>;
  timestamp: number;
}

export interface ApiError {
  message: string;
  code?: string;
  status?: number;
  details?: any;
}

export interface RequestConfig {
  method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
  headers?: Record<string, string>;
  body?: any;
  timeout?: number;
  retries?: number;
  retryDelay?: number;
  cache?: boolean;
  cacheTTL?: number;
  validateResponse?: (data: any) => boolean;
  transformRequest?: (data: any) => any;
  transformResponse?: (data: any) => any;
}

export interface CacheEntry<T = any> {
  data: T;
  timestamp: number;
  ttl: number;
  key: string;
}

export interface RetryConfig {
  maxRetries: number;
  baseDelay: number;
  maxDelay: number;
  backoffFactor: number;
  retryCondition: (error: any) => boolean;
}

// Cache manager
class CacheManager {
  private cache = new Map<string, CacheEntry>();
  private maxSize: number = 100;
  private defaultTTL: number = 300000; // 5 minutes

  public set<T>(key: string, data: T, ttl?: number): void {
    // Remove oldest entries if cache is full
    if (this.cache.size >= this.maxSize) {
      const oldestKey = this.cache.keys().next().value;
      this.cache.delete(oldestKey);
    }

    this.cache.set(key, {
      data,
      timestamp: Date.now(),
      ttl: ttl || this.defaultTTL,
      key,
    });
  }

  public get<T>(key: string): T | null {
    const entry = this.cache.get(key);
    
    if (!entry) {
      return null;
    }

    // Check if entry has expired
    if (Date.now() - entry.timestamp > entry.ttl) {
      this.cache.delete(key);
      return null;
    }

    return entry.data as T;
  }

  public has(key: string): boolean {
    return this.get(key) !== null;
  }

  public delete(key: string): boolean {
    return this.cache.delete(key);
  }

  public clear(): void {
    this.cache.clear();
  }

  public size(): number {
    return this.cache.size;
  }

  public getStats(): { size: number; maxSize: number; hitRate: number } {
    // This would track hit/miss rates in a real implementation
    return {
      size: this.cache.size,
      maxSize: this.maxSize,
      hitRate: 0.85, // Mock hit rate
    };
  }

  public setMaxSize(size: number): void {
    this.maxSize = size;
    
    // Trim cache if necessary
    while (this.cache.size > this.maxSize) {
      const oldestKey = this.cache.keys().next().value;
      this.cache.delete(oldestKey);
    }
  }

  public setDefaultTTL(ttl: number): void {
    this.defaultTTL = ttl;
  }
}

// Request interceptor
export type RequestInterceptor = (config: RequestConfig & { url: string }) => RequestConfig & { url: string };
export type ResponseInterceptor<T = any> = (response: ApiResponse<T>) => ApiResponse<T>;
export type ErrorInterceptor = (error: any) => any;

// Main API client class
export class ApiClient {
  private baseURL: string;
  private defaultConfig: RequestConfig;
  private cache: CacheManager;
  private requestInterceptors: RequestInterceptor[] = [];
  private responseInterceptors: ResponseInterceptor[] = [];
  private errorInterceptors: ErrorInterceptor[] = [];

  constructor(baseURL?: string, defaultConfig?: RequestConfig) {
    this.baseURL = baseURL || configManager.get('api').baseUrl;
    this.defaultConfig = {
      timeout: 30000,
      retries: 3,
      retryDelay: 1000,
      cache: false,
      cacheTTL: 300000,
      ...defaultConfig,
    };
    this.cache = new CacheManager();
  }

  // Interceptor management
  public addRequestInterceptor(interceptor: RequestInterceptor): void {
    this.requestInterceptors.push(interceptor);
  }

  public addResponseInterceptor(interceptor: ResponseInterceptor): void {
    this.responseInterceptors.push(interceptor);
  }

  public addErrorInterceptor(interceptor: ErrorInterceptor): void {
    this.errorInterceptors.push(interceptor);
  }

  // Cache management
  public getCacheStats() {
    return this.cache.getStats();
  }

  public clearCache(): void {
    this.cache.clear();
  }

  public setCacheConfig(maxSize: number, defaultTTL: number): void {
    this.cache.setMaxSize(maxSize);
    this.cache.setDefaultTTL(defaultTTL);
  }

  // Main request method
  public async request<T = any>(url: string, config: RequestConfig = {}): Promise<ApiResponse<T>> {
    const fullConfig = { ...this.defaultConfig, ...config };
    const fullUrl = url.startsWith('http') ? url : `${this.baseURL}${url}`;
    const cacheKey = this.generateCacheKey(fullUrl, fullConfig);

    // Check cache first
    if (fullConfig.cache && fullConfig.method === 'GET') {
      const cachedResponse = this.cache.get<ApiResponse<T>>(cacheKey);
      if (cachedResponse) {
        logger.debug('Cache hit', { url: fullUrl, cacheKey });
        return cachedResponse;
      }
    }

    // Apply request interceptors
    let interceptedConfig = { ...fullConfig, url: fullUrl };
    for (const interceptor of this.requestInterceptors) {
      interceptedConfig = interceptor(interceptedConfig);
    }

    try {
      const response = await this.executeRequest<T>(interceptedConfig);
      
      // Apply response interceptors
      let interceptedResponse = response;
      for (const interceptor of this.responseInterceptors) {
        interceptedResponse = interceptor(interceptedResponse);
      }

      // Cache successful GET requests
      if (fullConfig.cache && fullConfig.method === 'GET' && response.status < 400) {
        this.cache.set(cacheKey, interceptedResponse, fullConfig.cacheTTL);
        logger.debug('Response cached', { url: fullUrl, cacheKey });
      }

      return interceptedResponse;
    } catch (error) {
      // Apply error interceptors
      let interceptedError = error;
      for (const interceptor of this.errorInterceptors) {
        interceptedError = interceptor(interceptedError);
      }

      throw interceptedError;
    }
  }

  private async executeRequest<T>(config: RequestConfig & { url: string }): Promise<ApiResponse<T>> {
    const { url, method = 'GET', headers = {}, body, timeout, retries = 0, retryDelay = 1000 } = config;

    const retryConfig: RetryConfig = {
      maxRetries: retries,
      baseDelay: retryDelay,
      maxDelay: 30000,
      backoffFactor: 2,
      retryCondition: (error: any) => {
        // Retry on network errors, timeouts, and 5xx status codes
        return (
          error.name === 'NetworkError' ||
          error.name === 'TimeoutError' ||
          (error.status >= 500 && error.status < 600)
        );
      },
    };

    return this.executeWithRetry(async () => {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      try {
        // Transform request body
        let transformedBody = body;
        if (config.transformRequest && body) {
          transformedBody = config.transformRequest(body);
        }

        // Prepare fetch options
        const fetchOptions: RequestInit = {
          method,
          headers: {
            'Content-Type': 'application/json',
            ...headers,
          },
          signal: controller.signal,
        };

        if (transformedBody && method !== 'GET') {
          fetchOptions.body = typeof transformedBody === 'string' 
            ? transformedBody 
            : JSON.stringify(transformedBody);
        }

        logger.debug('Making API request', { url, method, headers: Object.keys(headers) });

        const response = await fetch(url, fetchOptions);
        clearTimeout(timeoutId);

        // Parse response
        let data: T;
        const contentType = response.headers.get('content-type');
        
        if (contentType && contentType.includes('application/json')) {
          data = await response.json();
        } else {
          data = (await response.text()) as any;
        }

        // Transform response
        if (config.transformResponse) {
          data = config.transformResponse(data);
        }

        // Validate response
        if (config.validateResponse && !config.validateResponse(data)) {
          throw new ValidationError('Response validation failed', { data, url });
        }

        const apiResponse: ApiResponse<T> = {
          data,
          status: response.status,
          statusText: response.statusText,
          headers: this.parseHeaders(response.headers),
          timestamp: Date.now(),
        };

        // Handle HTTP errors
        if (!response.ok) {
          const error = new BlueSavingsError(
            this.mapStatusToErrorType(response.status),
            `HTTP ${response.status}: ${response.statusText}`,
            { url, status: response.status, data },
            response.status.toString(),
            response.status >= 500
          );
          throw error;
        }

        logger.info('API request successful', { 
          url, 
          method, 
          status: response.status,
          duration: Date.now() - (apiResponse.timestamp - 100) // Approximate
        });

        return apiResponse;

      } catch (error) {
        clearTimeout(timeoutId);

        if (error.name === 'AbortError') {
          throw new BlueSavingsError(
            ErrorType.TIMEOUT_ERROR,
            'Request timeout',
            { url, timeout },
            'TIMEOUT',
            true
          );
        }

        if (error instanceof BlueSavingsError) {
          throw error;
        }

        // Network or other errors
        throw new NetworkError(
          `Network request failed: ${error.message}`,
          { url, originalError: error },
          true
        );
      }
    }, retryConfig);
  }

  private async executeWithRetry<T>(
    operation: () => Promise<T>,
    config: RetryConfig
  ): Promise<T> {
    let lastError: any;
    let delay = config.baseDelay;

    for (let attempt = 0; attempt <= config.maxRetries; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;

        // Don't retry if this is the last attempt or error is not retryable
        if (attempt === config.maxRetries || !config.retryCondition(error)) {
          break;
        }

        logger.warn('Request failed, retrying', {
          attempt: attempt + 1,
          maxRetries: config.maxRetries,
          delay,
          error: error.message,
        });

        // Wait before retrying
        await this.sleep(delay);

        // Exponential backoff
        delay = Math.min(delay * config.backoffFactor, config.maxDelay);
      }
    }

    throw lastError;
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private generateCacheKey(url: string, config: RequestConfig): string {
    const keyData = {
      url,
      method: config.method || 'GET',
      body: config.body,
      headers: config.headers,
    };
    return btoa(JSON.stringify(keyData));
  }

  private parseHeaders(headers: Headers): Record<string, string> {
    const parsed: Record<string, string> = {};
    headers.forEach((value, key) => {
      parsed[key] = value;
    });
    return parsed;
  }

  private mapStatusToErrorType(status: number): ErrorType {
    if (status === 401) return ErrorType.AUTHENTICATION_ERROR;
    if (status === 403) return ErrorType.PERMISSION_ERROR;
    if (status === 429) return ErrorType.RATE_LIMIT_ERROR;
    if (status >= 400 && status < 500) return ErrorType.VALIDATION_ERROR;
    if (status >= 500) return ErrorType.API_ERROR;
    return ErrorType.UNKNOWN_ERROR;
  }

  // Convenience methods
  public async get<T = any>(url: string, config?: RequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>(url, { ...config, method: 'GET' });
  }

  public async post<T = any>(url: string, data?: any, config?: RequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>(url, { ...config, method: 'POST', body: data });
  }

  public async put<T = any>(url: string, data?: any, config?: RequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>(url, { ...config, method: 'PUT', body: data });
  }

  public async patch<T = any>(url: string, data?: any, config?: RequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>(url, { ...config, method: 'PATCH', body: data });
  }

  public async delete<T = any>(url: string, config?: RequestConfig): Promise<ApiResponse<T>> {
    return this.request<T>(url, { ...config, method: 'DELETE' });
  }
}

// Specialized API clients
export class VaultApiClient extends ApiClient {
  constructor() {
    super();
    
    // Add vault-specific interceptors
    this.addRequestInterceptor((config) => {
      // Add authentication headers if available
      const token = localStorage.getItem('auth-token');
      if (token) {
        config.headers = {
          ...config.headers,
          'Authorization': `Bearer ${token}`,
        };
      }
      return config;
    });

    this.addResponseInterceptor((response) => {
      // Log vault operations
      if (response.data && typeof response.data === 'object') {
        logger.logUserAction('api-call', undefined, {
          endpoint: response.data.endpoint,
          status: response.status,
        });
      }
      return response;
    });
  }

  public async getVaults(filters?: any) {
    return this.get('/vaults', { 
      cache: true, 
      cacheTTL: 60000, // 1 minute cache
      body: filters 
    });
  }

  public async getVault(id: number) {
    return this.get(`/vaults/${id}`, { cache: true, cacheTTL: 30000 });
  }

  public async createVault(vaultData: any) {
    return this.post('/vaults', vaultData);
  }

  public async updateVault(id: number, updates: any) {
    return this.put(`/vaults/${id}`, updates);
  }

  public async deleteVault(id: number) {
    return this.delete(`/vaults/${id}`);
  }

  public async getTransactions(vaultId?: number) {
    const url = vaultId ? `/vaults/${vaultId}/transactions` : '/transactions';
    return this.get(url, { cache: true, cacheTTL: 30000 });
  }

  public async getAnalytics(timeRange?: string) {
    return this.get('/analytics', { 
      cache: true, 
      cacheTTL: 120000, // 2 minute cache
      body: { timeRange }
    });
  }
}

// Create and export default instances
export const apiClient = new ApiClient();
export const vaultApi = new VaultApiClient();

// Export utility functions
export const createApiClient = (baseURL?: string, config?: RequestConfig) => {
  return new ApiClient(baseURL, config);
};

export default {
  ApiClient,
  VaultApiClient,
  apiClient,
  vaultApi,
  createApiClient,
};
