/**
 * Comprehensive Data Validation and Sanitization Library
 * Provides robust validation, sanitization, and type checking utilities
 */

import { ValidationError } from './error-handling';

// Validation result types
export interface ValidationResult {
  isValid: boolean;
  errors: string[];
  warnings: string[];
  sanitizedValue?: any;
}

export interface ValidationRule<T = any> {
  name: string;
  validator: (value: T) => boolean | string;
  message?: string;
  severity?: 'error' | 'warning';
}

export interface SanitizationRule<T = any> {
  name: string;
  sanitizer: (value: T) => T;
}

// Base validator class
export class Validator<T = any> {
  private rules: ValidationRule<T>[] = [];
  private sanitizers: SanitizationRule<T>[] = [];

  public addRule(rule: ValidationRule<T>): this {
    this.rules.push(rule);
    return this;
  }

  public addSanitizer(sanitizer: SanitizationRule<T>): this {
    this.sanitizers.push(sanitizer);
    return this;
  }

  public validate(value: T): ValidationResult {
    const errors: string[] = [];
    const warnings: string[] = [];
    let sanitizedValue = value;

    // Apply sanitizers first
    for (const sanitizer of this.sanitizers) {
      try {
        sanitizedValue = sanitizer.sanitizer(sanitizedValue);
      } catch (error) {
        errors.push(`Sanitization failed for ${sanitizer.name}: ${error}`);
      }
    }

    // Apply validation rules
    for (const rule of this.rules) {
      try {
        const result = rule.validator(sanitizedValue);
        
        if (typeof result === 'string') {
          // Custom error message
          if (rule.severity === 'warning') {
            warnings.push(result);
          } else {
            errors.push(result);
          }
        } else if (!result) {
          // Boolean false result
          const message = rule.message || `Validation failed for rule: ${rule.name}`;
          if (rule.severity === 'warning') {
            warnings.push(message);
          } else {
            errors.push(message);
          }
        }
      } catch (error) {
        errors.push(`Validation error in rule ${rule.name}: ${error}`);
      }
    }

    return {
      isValid: errors.length === 0,
      errors,
      warnings,
      sanitizedValue,
    };
  }

  public validateAndThrow(value: T): T {
    const result = this.validate(value);
    if (!result.isValid) {
      throw new ValidationError(
        `Validation failed: ${result.errors.join(', ')}`,
        { value, errors: result.errors }
      );
    }
    return result.sanitizedValue;
  }
}

// Common validation rules
export const CommonRules = {
  required: <T>(message?: string): ValidationRule<T> => ({
    name: 'required',
    validator: (value: T) => value !== null && value !== undefined && value !== '',
    message: message || 'This field is required',
  }),

  minLength: (min: number, message?: string): ValidationRule<string> => ({
    name: 'minLength',
    validator: (value: string) => typeof value === 'string' && value.length >= min,
    message: message || `Must be at least ${min} characters long`,
  }),

  maxLength: (max: number, message?: string): ValidationRule<string> => ({
    name: 'maxLength',
    validator: (value: string) => typeof value === 'string' && value.length <= max,
    message: message || `Must be no more than ${max} characters long`,
  }),

  pattern: (regex: RegExp, message?: string): ValidationRule<string> => ({
    name: 'pattern',
    validator: (value: string) => typeof value === 'string' && regex.test(value),
    message: message || 'Invalid format',
  }),

  email: (message?: string): ValidationRule<string> => ({
    name: 'email',
    validator: (value: string) => {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      return typeof value === 'string' && emailRegex.test(value);
    },
    message: message || 'Invalid email address',
  }),

  url: (message?: string): ValidationRule<string> => ({
    name: 'url',
    validator: (value: string) => {
      try {
        new URL(value);
        return true;
      } catch {
        return false;
      }
    },
    message: message || 'Invalid URL',
  }),

  numeric: (message?: string): ValidationRule<string | number> => ({
    name: 'numeric',
    validator: (value: string | number) => {
      if (typeof value === 'number') return !isNaN(value);
      return typeof value === 'string' && !isNaN(Number(value));
    },
    message: message || 'Must be a valid number',
  }),

  min: (min: number, message?: string): ValidationRule<number> => ({
    name: 'min',
    validator: (value: number) => typeof value === 'number' && value >= min,
    message: message || `Must be at least ${min}`,
  }),

  max: (max: number, message?: string): ValidationRule<number> => ({
    name: 'max',
    validator: (value: number) => typeof value === 'number' && value <= max,
    message: message || `Must be no more than ${max}`,
  }),

  range: (min: number, max: number, message?: string): ValidationRule<number> => ({
    name: 'range',
    validator: (value: number) => typeof value === 'number' && value >= min && value <= max,
    message: message || `Must be between ${min} and ${max}`,
  }),

  integer: (message?: string): ValidationRule<number> => ({
    name: 'integer',
    validator: (value: number) => typeof value === 'number' && Number.isInteger(value),
    message: message || 'Must be an integer',
  }),

  positive: (message?: string): ValidationRule<number> => ({
    name: 'positive',
    validator: (value: number) => typeof value === 'number' && value > 0,
    message: message || 'Must be a positive number',
  }),

  nonNegative: (message?: string): ValidationRule<number> => ({
    name: 'nonNegative',
    validator: (value: number) => typeof value === 'number' && value >= 0,
    message: message || 'Must be non-negative',
  }),
};

// Common sanitization rules
export const CommonSanitizers = {
  trim: (): SanitizationRule<string> => ({
    name: 'trim',
    sanitizer: (value: string) => typeof value === 'string' ? value.trim() : value,
  }),

  toLowerCase: (): SanitizationRule<string> => ({
    name: 'toLowerCase',
    sanitizer: (value: string) => typeof value === 'string' ? value.toLowerCase() : value,
  }),

  toUpperCase: (): SanitizationRule<string> => ({
    name: 'toUpperCase',
    sanitizer: (value: string) => typeof value === 'string' ? value.toUpperCase() : value,
  }),

  removeWhitespace: (): SanitizationRule<string> => ({
    name: 'removeWhitespace',
    sanitizer: (value: string) => typeof value === 'string' ? value.replace(/\s+/g, '') : value,
  }),

  normalizeWhitespace: (): SanitizationRule<string> => ({
    name: 'normalizeWhitespace',
    sanitizer: (value: string) => typeof value === 'string' ? value.replace(/\s+/g, ' ').trim() : value,
  }),

  removeHtml: (): SanitizationRule<string> => ({
    name: 'removeHtml',
    sanitizer: (value: string) => typeof value === 'string' ? value.replace(/<[^>]*>/g, '') : value,
  }),

  escapeHtml: (): SanitizationRule<string> => ({
    name: 'escapeHtml',
    sanitizer: (value: string) => {
      if (typeof value !== 'string') return value;
      return value
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;');
    },
  }),

  toNumber: (): SanitizationRule<string | number> => ({
    name: 'toNumber',
    sanitizer: (value: string | number) => {
      if (typeof value === 'number') return value;
      const num = Number(value);
      return isNaN(num) ? value : num;
    },
  }),

  clamp: (min: number, max: number): SanitizationRule<number> => ({
    name: 'clamp',
    sanitizer: (value: number) => {
      if (typeof value !== 'number') return value;
      return Math.min(Math.max(value, min), max);
    },
  }),
};

// Blockchain-specific validators
export const BlockchainValidators = {
  ethereumAddress: (): Validator<string> => {
    return new Validator<string>()
      .addSanitizer(CommonSanitizers.trim())
      .addRule({
        name: 'ethereumAddress',
        validator: (value: string) => /^0x[a-fA-F0-9]{40}$/.test(value),
        message: 'Invalid Ethereum address format',
      });
  },

  transactionHash: (): Validator<string> => {
    return new Validator<string>()
      .addSanitizer(CommonSanitizers.trim())
      .addRule({
        name: 'transactionHash',
        validator: (value: string) => /^0x[a-fA-F0-9]{64}$/.test(value),
        message: 'Invalid transaction hash format',
      });
  },

  ethAmount: (): Validator<string | number> => {
    return new Validator<string | number>()
      .addRule(CommonRules.required('Amount is required'))
      .addRule(CommonRules.numeric('Amount must be a valid number'))
      .addRule({
        name: 'positiveAmount',
        validator: (value: string | number) => {
          const num = typeof value === 'string' ? parseFloat(value) : value;
          return num > 0;
        },
        message: 'Amount must be positive',
      })
      .addRule({
        name: 'maxDecimals',
        validator: (value: string | number) => {
          const str = value.toString();
          const decimalIndex = str.indexOf('.');
          if (decimalIndex === -1) return true;
          return str.length - decimalIndex - 1 <= 18;
        },
        message: 'Amount cannot have more than 18 decimal places',
      });
  },

  vaultName: (): Validator<string> => {
    return new Validator<string>()
      .addSanitizer(CommonSanitizers.trim())
      .addSanitizer(CommonSanitizers.normalizeWhitespace())
      .addRule(CommonRules.required('Vault name is required'))
      .addRule(CommonRules.minLength(3, 'Vault name must be at least 3 characters'))
      .addRule(CommonRules.maxLength(50, 'Vault name must be no more than 50 characters'))
      .addRule({
        name: 'validCharacters',
        validator: (value: string) => /^[a-zA-Z0-9\s\-_]+$/.test(value),
        message: 'Vault name can only contain letters, numbers, spaces, hyphens, and underscores',
      });
  },

  vaultDescription: (): Validator<string> => {
    return new Validator<string>()
      .addSanitizer(CommonSanitizers.trim())
      .addSanitizer(CommonSanitizers.normalizeWhitespace())
      .addSanitizer(CommonSanitizers.removeHtml())
      .addRule(CommonRules.maxLength(500, 'Description must be no more than 500 characters'));
  },

  unlockTimestamp: (): Validator<number> => {
    return new Validator<number>()
      .addRule(CommonRules.required('Unlock timestamp is required'))
      .addRule(CommonRules.integer('Unlock timestamp must be an integer'))
      .addRule({
        name: 'futureTimestamp',
        validator: (value: number) => value > Date.now(),
        message: 'Unlock time must be in the future',
      })
      .addRule({
        name: 'reasonableTimestamp',
        validator: (value: number) => {
          const maxFuture = Date.now() + (100 * 365 * 24 * 60 * 60 * 1000); // 100 years
          return value <= maxFuture;
        },
        message: 'Unlock time is too far in the future',
      });
  },

  goalAmount: (): Validator<string | number> => {
    return new Validator<string | number>()
      .addRule(CommonRules.numeric('Goal amount must be a valid number'))
      .addRule({
        name: 'positiveGoal',
        validator: (value: string | number) => {
          if (!value) return true; // Goal is optional
          const num = typeof value === 'string' ? parseFloat(value) : value;
          return num > 0;
        },
        message: 'Goal amount must be positive',
      })
      .addRule({
        name: 'reasonableGoal',
        validator: (value: string | number) => {
          if (!value) return true;
          const num = typeof value === 'string' ? parseFloat(value) : value;
          return num <= 1000000; // 1M ETH max
        },
        message: 'Goal amount is unreasonably large',
      });
  },
};

// Form validation utilities
export class FormValidator {
  private fields: Map<string, Validator> = new Map();
  private values: Map<string, any> = new Map();

  public addField(name: string, validator: Validator): this {
    this.fields.set(name, validator);
    return this;
  }

  public setValue(name: string, value: any): this {
    this.values.set(name, value);
    return this;
  }

  public setValues(values: Record<string, any>): this {
    Object.entries(values).forEach(([name, value]) => {
      this.values.set(name, value);
    });
    return this;
  }

  public validateField(name: string): ValidationResult {
    const validator = this.fields.get(name);
    const value = this.values.get(name);

    if (!validator) {
      return {
        isValid: false,
        errors: [`No validator found for field: ${name}`],
        warnings: [],
      };
    }

    return validator.validate(value);
  }

  public validateAll(): { isValid: boolean; results: Map<string, ValidationResult> } {
    const results = new Map<string, ValidationResult>();
    let isValid = true;

    for (const [name] of this.fields) {
      const result = this.validateField(name);
      results.set(name, result);
      if (!result.isValid) {
        isValid = false;
      }
    }

    return { isValid, results };
  }

  public getSanitizedValues(): Record<string, any> {
    const sanitized: Record<string, any> = {};

    for (const [name] of this.fields) {
      const result = this.validateField(name);
      if (result.sanitizedValue !== undefined) {
        sanitized[name] = result.sanitizedValue;
      }
    }

    return sanitized;
  }
}

// Utility functions
export const validateVaultCreation = (data: {
  name: string;
  description?: string;
  goalAmount?: string | number;
  unlockTimestamp?: number;
  initialDeposit: string | number;
}): ValidationResult => {
  const form = new FormValidator()
    .addField('name', BlockchainValidators.vaultName())
    .addField('description', BlockchainValidators.vaultDescription())
    .addField('goalAmount', BlockchainValidators.goalAmount())
    .addField('initialDeposit', BlockchainValidators.ethAmount())
    .setValues(data);

  if (data.unlockTimestamp) {
    form.addField('unlockTimestamp', BlockchainValidators.unlockTimestamp())
        .setValue('unlockTimestamp', data.unlockTimestamp);
  }

  const { isValid, results } = form.validateAll();
  const allErrors: string[] = [];
  const allWarnings: string[] = [];

  for (const result of results.values()) {
    allErrors.push(...result.errors);
    allWarnings.push(...result.warnings);
  }

  return {
    isValid,
    errors: allErrors,
    warnings: allWarnings,
    sanitizedValue: isValid ? form.getSanitizedValues() : undefined,
  };
};

export const validateDeposit = (amount: string | number, vaultId: number): ValidationResult => {
  const form = new FormValidator()
    .addField('amount', BlockchainValidators.ethAmount())
    .addField('vaultId', new Validator<number>()
      .addRule(CommonRules.required('Vault ID is required'))
      .addRule(CommonRules.integer('Vault ID must be an integer'))
      .addRule(CommonRules.positive('Vault ID must be positive'))
    )
    .setValues({ amount, vaultId });

  const { isValid, results } = form.validateAll();
  const allErrors: string[] = [];
  const allWarnings: string[] = [];

  for (const result of results.values()) {
    allErrors.push(...result.errors);
    allWarnings.push(...result.warnings);
  }

  return {
    isValid,
    errors: allErrors,
    warnings: allWarnings,
    sanitizedValue: isValid ? form.getSanitizedValues() : undefined,
  };
};

// Export main classes and utilities
export {
  Validator,
  FormValidator,
  ValidationResult,
  ValidationRule,
  SanitizationRule,
};

export default {
  Validator,
  FormValidator,
  CommonRules,
  CommonSanitizers,
  BlockchainValidators,
  validateVaultCreation,
  validateDeposit,
};
