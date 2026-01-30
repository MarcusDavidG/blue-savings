/**
 * Comprehensive utility library for BlueSavings protocol
 * Provides common functions for data manipulation, validation, and formatting
 */

// Type definitions
export interface VaultData {
  id: number;
  name: string;
  description: string;
  balance: bigint;
  goalAmount: bigint;
  unlockTimestamp: number;
  createdAt: number;
  owner: string;
}

export interface TransactionData {
  hash: string;
  type: string;
  amount: bigint;
  timestamp: number;
  status: 'pending' | 'confirmed' | 'failed';
}

// Constants
export const CONSTANTS = {
  SECONDS_PER_DAY: 86400,
  SECONDS_PER_HOUR: 3600,
  SECONDS_PER_MINUTE: 60,
  WEI_PER_ETH: BigInt('1000000000000000000'),
  GWEI_PER_ETH: BigInt('1000000000'),
  MAX_UINT256: BigInt('0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'),
  ZERO_ADDRESS: '0x0000000000000000000000000000000000000000',
  BASE_CHAIN_ID: 8453,
  BASE_SEPOLIA_CHAIN_ID: 84532,
} as const;

// Date and Time Utilities
export const dateUtils = {
  /**
   * Format timestamp to human-readable date
   */
  formatDate: (timestamp: number, options?: Intl.DateTimeFormatOptions): string => {
    const defaultOptions: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    };
    return new Date(timestamp).toLocaleDateString('en-US', { ...defaultOptions, ...options });
  },

  /**
   * Format timestamp to relative time (e.g., "2 hours ago")
   */
  formatRelativeTime: (timestamp: number): string => {
    const now = Date.now();
    const diff = now - timestamp;
    const seconds = Math.floor(diff / 1000);
    const minutes = Math.floor(seconds / 60);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days} day${days > 1 ? 's' : ''} ago`;
    if (hours > 0) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
    if (minutes > 0) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
    return 'Just now';
  },

  /**
   * Calculate time remaining until timestamp
   */
  getTimeRemaining: (timestamp: number): { days: number; hours: number; minutes: number; seconds: number } => {
    const now = Date.now();
    const diff = Math.max(0, timestamp - now);
    
    const days = Math.floor(diff / (1000 * 60 * 60 * 24));
    const hours = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((diff % (1000 * 60)) / 1000);

    return { days, hours, minutes, seconds };
  },

  /**
   * Check if timestamp is in the past
   */
  isPast: (timestamp: number): boolean => timestamp < Date.now(),

  /**
   * Check if timestamp is in the future
   */
  isFuture: (timestamp: number): boolean => timestamp > Date.now(),

  /**
   * Add days to current timestamp
   */
  addDays: (days: number): number => Date.now() + (days * 24 * 60 * 60 * 1000),

  /**
   * Get start of day timestamp
   */
  getStartOfDay: (timestamp: number): number => {
    const date = new Date(timestamp);
    date.setHours(0, 0, 0, 0);
    return date.getTime();
  },

  /**
   * Get end of day timestamp
   */
  getEndOfDay: (timestamp: number): number => {
    const date = new Date(timestamp);
    date.setHours(23, 59, 59, 999);
    return date.getTime();
  },
};

// BigInt and Number Utilities
export const numberUtils = {
  /**
   * Convert ETH to Wei
   */
  ethToWei: (eth: number | string): bigint => {
    const ethStr = typeof eth === 'number' ? eth.toString() : eth;
    const [whole, decimal = ''] = ethStr.split('.');
    const paddedDecimal = decimal.padEnd(18, '0').slice(0, 18);
    return BigInt(whole + paddedDecimal);
  },

  /**
   * Convert Wei to ETH
   */
  weiToEth: (wei: bigint): number => {
    return Number(wei) / Number(CONSTANTS.WEI_PER_ETH);
  },

  /**
   * Format Wei as ETH string
   */
  formatWeiAsEth: (wei: bigint, decimals: number = 4): string => {
    const eth = numberUtils.weiToEth(wei);
    return eth.toFixed(decimals);
  },

  /**
   * Format number with commas
   */
  formatWithCommas: (num: number): string => {
    return num.toLocaleString('en-US');
  },

  /**
   * Format percentage
   */
  formatPercentage: (value: number, decimals: number = 2): string => {
    return `${value.toFixed(decimals)}%`;
  },

  /**
   * Calculate percentage change
   */
  calculatePercentageChange: (oldValue: number, newValue: number): number => {
    if (oldValue === 0) return 0;
    return ((newValue - oldValue) / oldValue) * 100;
  },

  /**
   * Clamp number between min and max
   */
  clamp: (value: number, min: number, max: number): number => {
    return Math.min(Math.max(value, min), max);
  },

  /**
   * Round to specified decimal places
   */
  roundTo: (value: number, decimals: number): number => {
    const factor = Math.pow(10, decimals);
    return Math.round(value * factor) / factor;
  },

  /**
   * Check if number is within range
   */
  isInRange: (value: number, min: number, max: number): boolean => {
    return value >= min && value <= max;
  },
};

// String Utilities
export const stringUtils = {
  /**
   * Truncate string with ellipsis
   */
  truncate: (str: string, maxLength: number, suffix: string = '...'): string => {
    if (str.length <= maxLength) return str;
    return str.slice(0, maxLength - suffix.length) + suffix;
  },

  /**
   * Capitalize first letter
   */
  capitalize: (str: string): string => {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
  },

  /**
   * Convert to title case
   */
  toTitleCase: (str: string): string => {
    return str.replace(/\w\S*/g, (txt) => 
      txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase()
    );
  },

  /**
   * Convert to kebab case
   */
  toKebabCase: (str: string): string => {
    return str
      .replace(/([a-z])([A-Z])/g, '$1-$2')
      .replace(/[\s_]+/g, '-')
      .toLowerCase();
  },

  /**
   * Convert to camel case
   */
  toCamelCase: (str: string): string => {
    return str
      .replace(/(?:^\w|[A-Z]|\b\w)/g, (word, index) => 
        index === 0 ? word.toLowerCase() : word.toUpperCase()
      )
      .replace(/\s+/g, '');
  },

  /**
   * Remove HTML tags
   */
  stripHtml: (str: string): string => {
    return str.replace(/<[^>]*>/g, '');
  },

  /**
   * Generate random string
   */
  generateRandomString: (length: number): string => {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let result = '';
    for (let i = 0; i < length; i++) {
      result += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return result;
  },

  /**
   * Check if string is valid email
   */
  isValidEmail: (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  },

  /**
   * Check if string is valid URL
   */
  isValidUrl: (url: string): boolean => {
    try {
      new URL(url);
      return true;
    } catch {
      return false;
    }
  },
};

// Array Utilities
export const arrayUtils = {
  /**
   * Remove duplicates from array
   */
  unique: <T>(array: T[]): T[] => {
    return [...new Set(array)];
  },

  /**
   * Chunk array into smaller arrays
   */
  chunk: <T>(array: T[], size: number): T[][] => {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += size) {
      chunks.push(array.slice(i, i + size));
    }
    return chunks;
  },

  /**
   * Shuffle array
   */
  shuffle: <T>(array: T[]): T[] => {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  },

  /**
   * Group array by key
   */
  groupBy: <T, K extends keyof T>(array: T[], key: K): Record<string, T[]> => {
    return array.reduce((groups, item) => {
      const groupKey = String(item[key]);
      if (!groups[groupKey]) {
        groups[groupKey] = [];
      }
      groups[groupKey].push(item);
      return groups;
    }, {} as Record<string, T[]>);
  },

  /**
   * Sort array by key
   */
  sortBy: <T, K extends keyof T>(array: T[], key: K, direction: 'asc' | 'desc' = 'asc'): T[] => {
    return [...array].sort((a, b) => {
      const aVal = a[key];
      const bVal = b[key];
      
      if (aVal < bVal) return direction === 'asc' ? -1 : 1;
      if (aVal > bVal) return direction === 'asc' ? 1 : -1;
      return 0;
    });
  },

  /**
   * Find item by property
   */
  findBy: <T, K extends keyof T>(array: T[], key: K, value: T[K]): T | undefined => {
    return array.find(item => item[key] === value);
  },

  /**
   * Calculate sum of numeric property
   */
  sumBy: <T>(array: T[], getValue: (item: T) => number): number => {
    return array.reduce((sum, item) => sum + getValue(item), 0);
  },

  /**
   * Calculate average of numeric property
   */
  averageBy: <T>(array: T[], getValue: (item: T) => number): number => {
    if (array.length === 0) return 0;
    return arrayUtils.sumBy(array, getValue) / array.length;
  },
};

// Validation Utilities
export const validationUtils = {
  /**
   * Check if Ethereum address is valid
   */
  isValidAddress: (address: string): boolean => {
    return /^0x[a-fA-F0-9]{40}$/.test(address);
  },

  /**
   * Check if transaction hash is valid
   */
  isValidTxHash: (hash: string): boolean => {
    return /^0x[a-fA-F0-9]{64}$/.test(hash);
  },

  /**
   * Validate vault name
   */
  isValidVaultName: (name: string): boolean => {
    return name.length >= 3 && name.length <= 50 && /^[a-zA-Z0-9\s\-_]+$/.test(name);
  },

  /**
   * Validate vault description
   */
  isValidVaultDescription: (description: string): boolean => {
    return description.length <= 500;
  },

  /**
   * Validate amount (must be positive)
   */
  isValidAmount: (amount: string | number): boolean => {
    const num = typeof amount === 'string' ? parseFloat(amount) : amount;
    return !isNaN(num) && num > 0;
  },

  /**
   * Validate timestamp (must be in future)
   */
  isValidFutureTimestamp: (timestamp: number): boolean => {
    return timestamp > Date.now();
  },

  /**
   * Validate percentage (0-100)
   */
  isValidPercentage: (value: number): boolean => {
    return numberUtils.isInRange(value, 0, 100);
  },
};

// Crypto Utilities
export const cryptoUtils = {
  /**
   * Format address for display
   */
  formatAddress: (address: string, startChars: number = 6, endChars: number = 4): string => {
    if (!validationUtils.isValidAddress(address)) return address;
    return `${address.slice(0, startChars)}...${address.slice(-endChars)}`;
  },

  /**
   * Get explorer URL for address
   */
  getExplorerUrl: (address: string, chainId: number = CONSTANTS.BASE_CHAIN_ID): string => {
    const baseUrl = chainId === CONSTANTS.BASE_CHAIN_ID 
      ? 'https://basescan.org' 
      : 'https://sepolia.basescan.org';
    return `${baseUrl}/address/${address}`;
  },

  /**
   * Get transaction URL
   */
  getTxUrl: (hash: string, chainId: number = CONSTANTS.BASE_CHAIN_ID): string => {
    const baseUrl = chainId === CONSTANTS.BASE_CHAIN_ID 
      ? 'https://basescan.org' 
      : 'https://sepolia.basescan.org';
    return `${baseUrl}/tx/${hash}`;
  },

  /**
   * Generate deterministic color from address
   */
  getAddressColor: (address: string): string => {
    const hash = address.slice(2, 8);
    const r = parseInt(hash.slice(0, 2), 16);
    const g = parseInt(hash.slice(2, 4), 16);
    const b = parseInt(hash.slice(4, 6), 16);
    return `rgb(${r}, ${g}, ${b})`;
  },
};

// Storage Utilities
export const storageUtils = {
  /**
   * Set item in localStorage with error handling
   */
  setItem: (key: string, value: any): boolean => {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch (error) {
      console.error('Failed to save to localStorage:', error);
      return false;
    }
  },

  /**
   * Get item from localStorage with error handling
   */
  getItem: <T>(key: string, defaultValue?: T): T | null => {
    try {
      const item = localStorage.getItem(key);
      return item ? JSON.parse(item) : defaultValue || null;
    } catch (error) {
      console.error('Failed to read from localStorage:', error);
      return defaultValue || null;
    }
  },

  /**
   * Remove item from localStorage
   */
  removeItem: (key: string): boolean => {
    try {
      localStorage.removeItem(key);
      return true;
    } catch (error) {
      console.error('Failed to remove from localStorage:', error);
      return false;
    }
  },

  /**
   * Clear all localStorage
   */
  clear: (): boolean => {
    try {
      localStorage.clear();
      return true;
    } catch (error) {
      console.error('Failed to clear localStorage:', error);
      return false;
    }
  },

  /**
   * Get storage usage info
   */
  getStorageInfo: (): { used: number; available: number; percentage: number } => {
    let used = 0;
    for (let key in localStorage) {
      if (localStorage.hasOwnProperty(key)) {
        used += localStorage[key].length + key.length;
      }
    }
    
    const available = 5 * 1024 * 1024; // 5MB typical limit
    const percentage = (used / available) * 100;
    
    return { used, available, percentage };
  },
};

// Performance Utilities
export const performanceUtils = {
  /**
   * Debounce function calls
   */
  debounce: <T extends (...args: any[]) => any>(
    func: T,
    wait: number
  ): ((...args: Parameters<T>) => void) => {
    let timeout: NodeJS.Timeout;
    return (...args: Parameters<T>) => {
      clearTimeout(timeout);
      timeout = setTimeout(() => func(...args), wait);
    };
  },

  /**
   * Throttle function calls
   */
  throttle: <T extends (...args: any[]) => any>(
    func: T,
    limit: number
  ): ((...args: Parameters<T>) => void) => {
    let inThrottle: boolean;
    return (...args: Parameters<T>) => {
      if (!inThrottle) {
        func(...args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  },

  /**
   * Measure execution time
   */
  measureTime: async <T>(fn: () => Promise<T> | T): Promise<{ result: T; time: number }> => {
    const start = performance.now();
    const result = await fn();
    const time = performance.now() - start;
    return { result, time };
  },

  /**
   * Create delay/sleep function
   */
  sleep: (ms: number): Promise<void> => {
    return new Promise(resolve => setTimeout(resolve, ms));
  },
};

// Export all utilities
export const utils = {
  date: dateUtils,
  number: numberUtils,
  string: stringUtils,
  array: arrayUtils,
  validation: validationUtils,
  crypto: cryptoUtils,
  storage: storageUtils,
  performance: performanceUtils,
  constants: CONSTANTS,
};

export default utils;
