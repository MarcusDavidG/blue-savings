export const REGEX_PATTERNS = {
  ETH_ADDRESS: /^0x[a-fA-F0-9]{40}$/,
  NUMBER: /^\d+\.?\d*$/,
  INTEGER: /^\d+$/,
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  URL: /^https?:\/\/.+/,
} as const
