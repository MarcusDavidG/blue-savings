/**
 * Comprehensive Error Handling and Logging System for BlueSavings
 * Provides centralized error management, logging, and monitoring
 */

// Error types and interfaces
export enum ErrorType {
  NETWORK_ERROR = 'NETWORK_ERROR',
  CONTRACT_ERROR = 'CONTRACT_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
  AUTHENTICATION_ERROR = 'AUTHENTICATION_ERROR',
  PERMISSION_ERROR = 'PERMISSION_ERROR',
  RATE_LIMIT_ERROR = 'RATE_LIMIT_ERROR',
  TIMEOUT_ERROR = 'TIMEOUT_ERROR',
  UNKNOWN_ERROR = 'UNKNOWN_ERROR',
  USER_REJECTED = 'USER_REJECTED',
  INSUFFICIENT_FUNDS = 'INSUFFICIENT_FUNDS',
  TRANSACTION_FAILED = 'TRANSACTION_FAILED',
  API_ERROR = 'API_ERROR',
  STORAGE_ERROR = 'STORAGE_ERROR',
}

export enum LogLevel {
  DEBUG = 0,
  INFO = 1,
  WARN = 2,
  ERROR = 3,
  FATAL = 4,
}

export interface ErrorContext {
  userId?: string;
  sessionId?: string;
  userAgent?: string;
  url?: string;
  timestamp: number;
  stackTrace?: string;
  additionalData?: Record<string, any>;
}

export interface LogEntry {
  id: string;
  level: LogLevel;
  message: string;
  timestamp: number;
  context?: ErrorContext;
  tags?: string[];
  source?: string;
}

export interface ErrorReport {
  id: string;
  type: ErrorType;
  message: string;
  context: ErrorContext;
  resolved: boolean;
  resolvedAt?: number;
  resolution?: string;
  occurrenceCount: number;
  firstOccurrence: number;
  lastOccurrence: number;
}

// Custom error classes
export class BlueSavingsError extends Error {
  public readonly type: ErrorType;
  public readonly context: ErrorContext;
  public readonly code?: string;
  public readonly retryable: boolean;

  constructor(
    type: ErrorType,
    message: string,
    context: Partial<ErrorContext> = {},
    code?: string,
    retryable: boolean = false
  ) {
    super(message);
    this.name = 'BlueSavingsError';
    this.type = type;
    this.code = code;
    this.retryable = retryable;
    this.context = {
      timestamp: Date.now(),
      stackTrace: this.stack,
      ...context,
    };
  }
}

export class ContractError extends BlueSavingsError {
  constructor(message: string, context: Partial<ErrorContext> = {}, code?: string) {
    super(ErrorType.CONTRACT_ERROR, message, context, code, false);
    this.name = 'ContractError';
  }
}

export class NetworkError extends BlueSavingsError {
  constructor(message: string, context: Partial<ErrorContext> = {}, retryable: boolean = true) {
    super(ErrorType.NETWORK_ERROR, message, context, undefined, retryable);
    this.name = 'NetworkError';
  }
}

export class ValidationError extends BlueSavingsError {
  constructor(message: string, context: Partial<ErrorContext> = {}) {
    super(ErrorType.VALIDATION_ERROR, message, context, undefined, false);
    this.name = 'ValidationError';
  }
}

// Logger class
export class Logger {
  private static instance: Logger;
  private logs: LogEntry[] = [];
  private maxLogs: number = 1000;
  private minLevel: LogLevel = LogLevel.INFO;
  private listeners: Array<(entry: LogEntry) => void> = [];

  private constructor() {
    this.setupGlobalErrorHandlers();
  }

  public static getInstance(): Logger {
    if (!Logger.instance) {
      Logger.instance = new Logger();
    }
    return Logger.instance;
  }

  private setupGlobalErrorHandlers(): void {
    // Handle unhandled promise rejections
    if (typeof window !== 'undefined') {
      window.addEventListener('unhandledrejection', (event) => {
        this.error('Unhandled promise rejection', {
          error: event.reason,
          promise: event.promise,
        });
      });

      // Handle global errors
      window.addEventListener('error', (event) => {
        this.error('Global error', {
          message: event.message,
          filename: event.filename,
          lineno: event.lineno,
          colno: event.colno,
          error: event.error,
        });
      });
    }
  }

  public setMinLevel(level: LogLevel): void {
    this.minLevel = level;
  }

  public setMaxLogs(max: number): void {
    this.maxLogs = max;
    this.trimLogs();
  }

  private trimLogs(): void {
    if (this.logs.length > this.maxLogs) {
      this.logs = this.logs.slice(-this.maxLogs);
    }
  }

  private createLogEntry(
    level: LogLevel,
    message: string,
    context?: any,
    tags?: string[],
    source?: string
  ): LogEntry {
    return {
      id: this.generateId(),
      level,
      message,
      timestamp: Date.now(),
      context: context ? this.sanitizeContext(context) : undefined,
      tags,
      source,
    };
  }

  private sanitizeContext(context: any): ErrorContext {
    // Remove sensitive information and circular references
    const sanitized: any = {};
    
    try {
      for (const [key, value] of Object.entries(context)) {
        if (this.isSensitiveKey(key)) {
          sanitized[key] = '[REDACTED]';
        } else if (typeof value === 'object' && value !== null) {
          sanitized[key] = JSON.parse(JSON.stringify(value));
        } else {
          sanitized[key] = value;
        }
      }
    } catch (error) {
      sanitized.error = 'Failed to sanitize context';
    }

    return {
      timestamp: Date.now(),
      url: typeof window !== 'undefined' ? window.location.href : undefined,
      userAgent: typeof navigator !== 'undefined' ? navigator.userAgent : undefined,
      ...sanitized,
    };
  }

  private isSensitiveKey(key: string): boolean {
    const sensitiveKeys = [
      'password',
      'token',
      'secret',
      'key',
      'privateKey',
      'mnemonic',
      'seed',
      'auth',
      'authorization',
    ];
    return sensitiveKeys.some(sensitive => 
      key.toLowerCase().includes(sensitive.toLowerCase())
    );
  }

  private generateId(): string {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  private log(level: LogLevel, message: string, context?: any, tags?: string[], source?: string): void {
    if (level < this.minLevel) return;

    const entry = this.createLogEntry(level, message, context, tags, source);
    this.logs.push(entry);
    this.trimLogs();

    // Notify listeners
    this.listeners.forEach(listener => {
      try {
        listener(entry);
      } catch (error) {
        console.error('Error in log listener:', error);
      }
    });

    // Console output
    this.outputToConsole(entry);

    // Send to external services in production
    if (level >= LogLevel.ERROR) {
      this.sendToExternalService(entry);
    }
  }

  private outputToConsole(entry: LogEntry): void {
    const timestamp = new Date(entry.timestamp).toISOString();
    const prefix = `[${timestamp}] [${LogLevel[entry.level]}]`;
    const message = `${prefix} ${entry.message}`;

    switch (entry.level) {
      case LogLevel.DEBUG:
        console.debug(message, entry.context);
        break;
      case LogLevel.INFO:
        console.info(message, entry.context);
        break;
      case LogLevel.WARN:
        console.warn(message, entry.context);
        break;
      case LogLevel.ERROR:
      case LogLevel.FATAL:
        console.error(message, entry.context);
        break;
    }
  }

  private async sendToExternalService(entry: LogEntry): Promise<void> {
    // In a real application, this would send to services like Sentry, LogRocket, etc.
    try {
      // Example: Send to monitoring service
      // await fetch('/api/logs', {
      //   method: 'POST',
      //   headers: { 'Content-Type': 'application/json' },
      //   body: JSON.stringify(entry),
      // });
    } catch (error) {
      console.error('Failed to send log to external service:', error);
    }
  }

  // Public logging methods
  public debug(message: string, context?: any, tags?: string[]): void {
    this.log(LogLevel.DEBUG, message, context, tags, 'DEBUG');
  }

  public info(message: string, context?: any, tags?: string[]): void {
    this.log(LogLevel.INFO, message, context, tags, 'INFO');
  }

  public warn(message: string, context?: any, tags?: string[]): void {
    this.log(LogLevel.WARN, message, context, tags, 'WARN');
  }

  public error(message: string, context?: any, tags?: string[]): void {
    this.log(LogLevel.ERROR, message, context, tags, 'ERROR');
  }

  public fatal(message: string, context?: any, tags?: string[]): void {
    this.log(LogLevel.FATAL, message, context, tags, 'FATAL');
  }

  // Specialized logging methods
  public logTransaction(txHash: string, type: string, status: 'pending' | 'success' | 'failed', context?: any): void {
    this.info(`Transaction ${status}: ${type}`, {
      txHash,
      type,
      status,
      ...context,
    }, ['transaction', type, status]);
  }

  public logUserAction(action: string, userId?: string, context?: any): void {
    this.info(`User action: ${action}`, {
      action,
      userId,
      ...context,
    }, ['user-action', action]);
  }

  public logPerformance(operation: string, duration: number, context?: any): void {
    const level = duration > 5000 ? LogLevel.WARN : LogLevel.INFO;
    this.log(level, `Performance: ${operation} took ${duration}ms`, {
      operation,
      duration,
      ...context,
    }, ['performance', operation]);
  }

  // Query methods
  public getLogs(filter?: {
    level?: LogLevel;
    tags?: string[];
    since?: number;
    limit?: number;
  }): LogEntry[] {
    let filtered = [...this.logs];

    if (filter) {
      if (filter.level !== undefined) {
        filtered = filtered.filter(log => log.level >= filter.level!);
      }

      if (filter.tags && filter.tags.length > 0) {
        filtered = filtered.filter(log => 
          log.tags && filter.tags!.some(tag => log.tags!.includes(tag))
        );
      }

      if (filter.since) {
        filtered = filtered.filter(log => log.timestamp >= filter.since!);
      }

      if (filter.limit) {
        filtered = filtered.slice(-filter.limit);
      }
    }

    return filtered;
  }

  public getErrorLogs(): LogEntry[] {
    return this.getLogs({ level: LogLevel.ERROR });
  }

  public clearLogs(): void {
    this.logs = [];
  }

  public subscribe(listener: (entry: LogEntry) => void): () => void {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  public exportLogs(): string {
    return JSON.stringify(this.logs, null, 2);
  }
}

// Error handler class
export class ErrorHandler {
  private static instance: ErrorHandler;
  private logger: Logger;
  private errorReports: Map<string, ErrorReport> = new Map();

  private constructor() {
    this.logger = Logger.getInstance();
  }

  public static getInstance(): ErrorHandler {
    if (!ErrorHandler.instance) {
      ErrorHandler.instance = new ErrorHandler();
    }
    return ErrorHandler.instance;
  }

  public handleError(error: Error | BlueSavingsError, context?: Partial<ErrorContext>): string {
    const errorId = this.generateErrorId();
    
    if (error instanceof BlueSavingsError) {
      return this.handleBlueSavingsError(error, errorId, context);
    } else {
      return this.handleGenericError(error, errorId, context);
    }
  }

  private handleBlueSavingsError(
    error: BlueSavingsError,
    errorId: string,
    context?: Partial<ErrorContext>
  ): string {
    const mergedContext = { ...error.context, ...context };
    
    this.logger.error(`${error.type}: ${error.message}`, {
      errorId,
      type: error.type,
      code: error.code,
      retryable: error.retryable,
      ...mergedContext,
    }, ['error', error.type.toLowerCase()]);

    this.recordErrorReport(errorId, error.type, error.message, mergedContext);
    
    return errorId;
  }

  private handleGenericError(
    error: Error,
    errorId: string,
    context?: Partial<ErrorContext>
  ): string {
    const errorType = this.classifyError(error);
    const mergedContext = {
      timestamp: Date.now(),
      stackTrace: error.stack,
      ...context,
    };

    this.logger.error(`${errorType}: ${error.message}`, {
      errorId,
      type: errorType,
      name: error.name,
      ...mergedContext,
    }, ['error', errorType.toLowerCase()]);

    this.recordErrorReport(errorId, errorType, error.message, mergedContext);
    
    return errorId;
  }

  private classifyError(error: Error): ErrorType {
    const message = error.message.toLowerCase();
    const name = error.name.toLowerCase();

    if (message.includes('network') || message.includes('fetch')) {
      return ErrorType.NETWORK_ERROR;
    }
    
    if (message.includes('timeout')) {
      return ErrorType.TIMEOUT_ERROR;
    }
    
    if (message.includes('rejected') || message.includes('denied')) {
      return ErrorType.USER_REJECTED;
    }
    
    if (message.includes('insufficient') || message.includes('balance')) {
      return ErrorType.INSUFFICIENT_FUNDS;
    }
    
    if (name.includes('validation') || message.includes('invalid')) {
      return ErrorType.VALIDATION_ERROR;
    }

    return ErrorType.UNKNOWN_ERROR;
  }

  private recordErrorReport(
    id: string,
    type: ErrorType,
    message: string,
    context: ErrorContext
  ): void {
    const key = `${type}-${message}`;
    const existing = this.errorReports.get(key);
    
    if (existing) {
      existing.occurrenceCount++;
      existing.lastOccurrence = Date.now();
    } else {
      this.errorReports.set(key, {
        id,
        type,
        message,
        context,
        resolved: false,
        occurrenceCount: 1,
        firstOccurrence: Date.now(),
        lastOccurrence: Date.now(),
      });
    }
  }

  private generateErrorId(): string {
    return `err-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
  }

  public getErrorReports(): ErrorReport[] {
    return Array.from(this.errorReports.values());
  }

  public resolveError(errorId: string, resolution: string): boolean {
    for (const report of this.errorReports.values()) {
      if (report.id === errorId) {
        report.resolved = true;
        report.resolvedAt = Date.now();
        report.resolution = resolution;
        return true;
      }
    }
    return false;
  }

  public clearErrorReports(): void {
    this.errorReports.clear();
  }
}

// Utility functions
export const createErrorHandler = () => ErrorHandler.getInstance();
export const createLogger = () => Logger.getInstance();

// Global error handling utilities
export const handleAsyncError = async <T>(
  operation: () => Promise<T>,
  errorHandler?: (error: Error) => void
): Promise<T | null> => {
  try {
    return await operation();
  } catch (error) {
    const handler = errorHandler || createErrorHandler().handleError;
    handler(error as Error);
    return null;
  }
};

export const withErrorBoundary = <T extends any[], R>(
  fn: (...args: T) => R,
  errorHandler?: (error: Error) => R
): ((...args: T) => R) => {
  return (...args: T): R => {
    try {
      return fn(...args);
    } catch (error) {
      if (errorHandler) {
        return errorHandler(error as Error);
      }
      createErrorHandler().handleError(error as Error);
      throw error;
    }
  };
};

// Export singleton instances
export const logger = Logger.getInstance();
export const errorHandler = ErrorHandler.getInstance();

export default {
  Logger,
  ErrorHandler,
  BlueSavingsError,
  ContractError,
  NetworkError,
  ValidationError,
  logger,
  errorHandler,
  handleAsyncError,
  withErrorBoundary,
};
