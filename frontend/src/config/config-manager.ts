/**
 * Configuration Management System for BlueSavings
 * Centralized configuration with environment-specific settings
 */

// Environment types
export type Environment = 'development' | 'staging' | 'production';

// Network configuration
export interface NetworkConfig {
  chainId: number;
  name: string;
  rpcUrl: string;
  explorerUrl: string;
  nativeCurrency: {
    name: string;
    symbol: string;
    decimals: number;
  };
  contracts: {
    savingsVault: string;
    vaultAnalytics: string;
    riskAssessment: string;
    emergencyPause: string;
    vaultInsurance: string;
    yieldFarming: string;
    governance: string;
    migrationManager: string;
    eventMonitor: string;
    rebalancer: string;
    statsAggregator: string;
  };
}

// API configuration
export interface ApiConfig {
  baseUrl: string;
  timeout: number;
  retryAttempts: number;
  retryDelay: number;
  endpoints: {
    vaults: string;
    transactions: string;
    analytics: string;
    health: string;
    stats: string;
  };
}

// Feature flags
export interface FeatureFlags {
  enableYieldFarming: boolean;
  enableInsurance: boolean;
  enableGovernance: boolean;
  enableMigration: boolean;
  enableRebalancing: boolean;
  enableAnalytics: boolean;
  enableNotifications: boolean;
  enableSharing: boolean;
  enableTemplates: boolean;
  enableComparison: boolean;
  enableBackup: boolean;
  enablePerformanceMonitoring: boolean;
  enableAdvancedFilters: boolean;
  enableBatchOperations: boolean;
  enableEmergencyMode: boolean;
}

// UI configuration
export interface UiConfig {
  theme: {
    primaryColor: string;
    secondaryColor: string;
    accentColor: string;
    backgroundColor: string;
    textColor: string;
    borderRadius: string;
    fontFamily: string;
  };
  layout: {
    maxWidth: string;
    sidebarWidth: string;
    headerHeight: string;
    footerHeight: string;
  };
  animations: {
    duration: number;
    easing: string;
    enableAnimations: boolean;
  };
  pagination: {
    defaultPageSize: number;
    pageSizeOptions: number[];
  };
}

// Security configuration
export interface SecurityConfig {
  maxTransactionAmount: string; // in ETH
  maxVaultsPerUser: number;
  sessionTimeout: number; // in minutes
  rateLimiting: {
    enabled: boolean;
    maxRequests: number;
    windowMs: number;
  };
  contentSecurityPolicy: {
    enabled: boolean;
    directives: Record<string, string[]>;
  };
}

// Performance configuration
export interface PerformanceConfig {
  caching: {
    enabled: boolean;
    ttl: number; // in seconds
    maxSize: number; // in MB
  };
  bundling: {
    enableCodeSplitting: boolean;
    enableTreeShaking: boolean;
    enableMinification: boolean;
  };
  monitoring: {
    enableMetrics: boolean;
    enableErrorTracking: boolean;
    sampleRate: number;
  };
}

// Complete application configuration
export interface AppConfig {
  environment: Environment;
  version: string;
  buildTime: string;
  network: NetworkConfig;
  api: ApiConfig;
  features: FeatureFlags;
  ui: UiConfig;
  security: SecurityConfig;
  performance: PerformanceConfig;
}

// Base configuration
const baseConfig: Omit<AppConfig, 'environment' | 'network'> = {
  version: '1.2.0',
  buildTime: new Date().toISOString(),
  
  api: {
    baseUrl: '/api',
    timeout: 30000,
    retryAttempts: 3,
    retryDelay: 1000,
    endpoints: {
      vaults: '/vaults',
      transactions: '/transactions',
      analytics: '/analytics',
      health: '/health',
      stats: '/stats',
    },
  },

  features: {
    enableYieldFarming: true,
    enableInsurance: true,
    enableGovernance: true,
    enableMigration: true,
    enableRebalancing: true,
    enableAnalytics: true,
    enableNotifications: true,
    enableSharing: true,
    enableTemplates: true,
    enableComparison: true,
    enableBackup: true,
    enablePerformanceMonitoring: true,
    enableAdvancedFilters: true,
    enableBatchOperations: true,
    enableEmergencyMode: false,
  },

  ui: {
    theme: {
      primaryColor: '#3B82F6',
      secondaryColor: '#6B7280',
      accentColor: '#10B981',
      backgroundColor: '#FFFFFF',
      textColor: '#111827',
      borderRadius: '0.5rem',
      fontFamily: 'Inter, system-ui, sans-serif',
    },
    layout: {
      maxWidth: '1200px',
      sidebarWidth: '256px',
      headerHeight: '64px',
      footerHeight: '80px',
    },
    animations: {
      duration: 200,
      easing: 'ease-in-out',
      enableAnimations: true,
    },
    pagination: {
      defaultPageSize: 20,
      pageSizeOptions: [10, 20, 50, 100],
    },
  },

  security: {
    maxTransactionAmount: '100',
    maxVaultsPerUser: 50,
    sessionTimeout: 60,
    rateLimiting: {
      enabled: true,
      maxRequests: 100,
      windowMs: 60000,
    },
    contentSecurityPolicy: {
      enabled: true,
      directives: {
        'default-src': ["'self'"],
        'script-src': ["'self'", "'unsafe-inline'"],
        'style-src': ["'self'", "'unsafe-inline'"],
        'img-src': ["'self'", 'data:', 'https:'],
        'connect-src': ["'self'", 'https://base.org', 'https://sepolia.base.org'],
      },
    },
  },

  performance: {
    caching: {
      enabled: true,
      ttl: 300,
      maxSize: 50,
    },
    bundling: {
      enableCodeSplitting: true,
      enableTreeShaking: true,
      enableMinification: true,
    },
    monitoring: {
      enableMetrics: true,
      enableErrorTracking: true,
      sampleRate: 0.1,
    },
  },
};

// Network configurations
const networks: Record<string, NetworkConfig> = {
  base: {
    chainId: 8453,
    name: 'Base',
    rpcUrl: 'https://mainnet.base.org',
    explorerUrl: 'https://basescan.org',
    nativeCurrency: {
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
    },
    contracts: {
      savingsVault: '0xf185cec4B72385CeaDE58507896E81F05E8b6c6a',
      vaultAnalytics: '0x0000000000000000000000000000000000000000',
      riskAssessment: '0x0000000000000000000000000000000000000000',
      emergencyPause: '0x0000000000000000000000000000000000000000',
      vaultInsurance: '0x0000000000000000000000000000000000000000',
      yieldFarming: '0x0000000000000000000000000000000000000000',
      governance: '0x0000000000000000000000000000000000000000',
      migrationManager: '0x0000000000000000000000000000000000000000',
      eventMonitor: '0x0000000000000000000000000000000000000000',
      rebalancer: '0x0000000000000000000000000000000000000000',
      statsAggregator: '0x0000000000000000000000000000000000000000',
    },
  },

  baseSepolia: {
    chainId: 84532,
    name: 'Base Sepolia',
    rpcUrl: 'https://sepolia.base.org',
    explorerUrl: 'https://sepolia.basescan.org',
    nativeCurrency: {
      name: 'Ethereum',
      symbol: 'ETH',
      decimals: 18,
    },
    contracts: {
      savingsVault: '0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402',
      vaultAnalytics: '0x0000000000000000000000000000000000000000',
      riskAssessment: '0x0000000000000000000000000000000000000000',
      emergencyPause: '0x0000000000000000000000000000000000000000',
      vaultInsurance: '0x0000000000000000000000000000000000000000',
      yieldFarming: '0x0000000000000000000000000000000000000000',
      governance: '0x0000000000000000000000000000000000000000',
      migrationManager: '0x0000000000000000000000000000000000000000',
      eventMonitor: '0x0000000000000000000000000000000000000000',
      rebalancer: '0x0000000000000000000000000000000000000000',
      statsAggregator: '0x0000000000000000000000000000000000000000',
    },
  },
};

// Environment-specific configurations
const environmentConfigs: Record<Environment, Partial<AppConfig>> = {
  development: {
    environment: 'development',
    network: networks.baseSepolia,
    api: {
      ...baseConfig.api,
      baseUrl: 'http://localhost:3001/api',
    },
    features: {
      ...baseConfig.features,
      enableEmergencyMode: true,
    },
    performance: {
      ...baseConfig.performance,
      monitoring: {
        ...baseConfig.performance.monitoring,
        enableMetrics: false,
        enableErrorTracking: false,
      },
    },
  },

  staging: {
    environment: 'staging',
    network: networks.baseSepolia,
    api: {
      ...baseConfig.api,
      baseUrl: 'https://staging-api.bluesavings.com/api',
    },
    features: {
      ...baseConfig.features,
      enableEmergencyMode: true,
    },
  },

  production: {
    environment: 'production',
    network: networks.base,
    api: {
      ...baseConfig.api,
      baseUrl: 'https://api.bluesavings.com/api',
    },
    ui: {
      ...baseConfig.ui,
      animations: {
        ...baseConfig.ui.animations,
        enableAnimations: true,
      },
    },
  },
};

// Configuration manager class
export class ConfigManager {
  private static instance: ConfigManager;
  private config: AppConfig;
  private listeners: Array<(config: AppConfig) => void> = [];

  private constructor() {
    this.config = this.loadConfig();
  }

  public static getInstance(): ConfigManager {
    if (!ConfigManager.instance) {
      ConfigManager.instance = new ConfigManager();
    }
    return ConfigManager.instance;
  }

  private loadConfig(): AppConfig {
    const environment = this.getEnvironment();
    const envConfig = environmentConfigs[environment];
    
    return {
      ...baseConfig,
      ...envConfig,
      environment,
    } as AppConfig;
  }

  private getEnvironment(): Environment {
    // Check environment variables
    if (typeof process !== 'undefined' && process.env) {
      const nodeEnv = process.env.NODE_ENV;
      if (nodeEnv === 'production') return 'production';
      if (nodeEnv === 'staging') return 'staging';
      return 'development';
    }

    // Check hostname for browser environment
    if (typeof window !== 'undefined') {
      const hostname = window.location.hostname;
      if (hostname === 'bluesavings.com' || hostname === 'www.bluesavings.com') {
        return 'production';
      }
      if (hostname.includes('staging')) {
        return 'staging';
      }
    }

    return 'development';
  }

  public getConfig(): AppConfig {
    return { ...this.config };
  }

  public get<K extends keyof AppConfig>(key: K): AppConfig[K] {
    return this.config[key];
  }

  public updateConfig(updates: Partial<AppConfig>): void {
    this.config = { ...this.config, ...updates };
    this.notifyListeners();
  }

  public updateFeatureFlag(flag: keyof FeatureFlags, enabled: boolean): void {
    this.config.features = { ...this.config.features, [flag]: enabled };
    this.notifyListeners();
  }

  public isFeatureEnabled(flag: keyof FeatureFlags): boolean {
    return this.config.features[flag];
  }

  public getNetworkConfig(): NetworkConfig {
    return this.config.network;
  }

  public getContractAddress(contract: keyof NetworkConfig['contracts']): string {
    return this.config.network.contracts[contract];
  }

  public subscribe(listener: (config: AppConfig) => void): () => void {
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index > -1) {
        this.listeners.splice(index, 1);
      }
    };
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this.config));
  }

  public exportConfig(): string {
    return JSON.stringify(this.config, null, 2);
  }

  public importConfig(configJson: string): void {
    try {
      const importedConfig = JSON.parse(configJson);
      this.config = { ...this.config, ...importedConfig };
      this.notifyListeners();
    } catch (error) {
      console.error('Failed to import configuration:', error);
      throw new Error('Invalid configuration format');
    }
  }

  public resetToDefaults(): void {
    this.config = this.loadConfig();
    this.notifyListeners();
  }

  public validateConfig(): { isValid: boolean; errors: string[] } {
    const errors: string[] = [];

    // Validate network configuration
    if (!this.config.network.chainId) {
      errors.push('Network chain ID is required');
    }

    if (!this.config.network.rpcUrl) {
      errors.push('Network RPC URL is required');
    }

    // Validate contract addresses
    const contracts = this.config.network.contracts;
    Object.entries(contracts).forEach(([name, address]) => {
      if (!address || address === '0x0000000000000000000000000000000000000000') {
        errors.push(`Contract address for ${name} is not set`);
      }
    });

    // Validate API configuration
    if (!this.config.api.baseUrl) {
      errors.push('API base URL is required');
    }

    if (this.config.api.timeout <= 0) {
      errors.push('API timeout must be positive');
    }

    // Validate security settings
    if (this.config.security.maxVaultsPerUser <= 0) {
      errors.push('Max vaults per user must be positive');
    }

    if (this.config.security.sessionTimeout <= 0) {
      errors.push('Session timeout must be positive');
    }

    return {
      isValid: errors.length === 0,
      errors,
    };
  }
}

// Export singleton instance
export const configManager = ConfigManager.getInstance();

// Export configuration getter functions
export const getConfig = () => configManager.getConfig();
export const isFeatureEnabled = (flag: keyof FeatureFlags) => configManager.isFeatureEnabled(flag);
export const getNetworkConfig = () => configManager.getNetworkConfig();
export const getContractAddress = (contract: keyof NetworkConfig['contracts']) => 
  configManager.getContractAddress(contract);

// Export default configuration
export default configManager;
