export const API_ENDPOINTS = {
  VAULTS: '/api/vaults',
  VAULT_BY_ID: (id: string) => `/api/vault/${id}`,
  USER: '/api/user',
  STATS: '/api/stats',
  TRANSACTIONS: '/api/transactions',
  FEES: '/api/fees',
  ANALYTICS: '/api/analytics',
  HEALTH: '/api/health',
  STATUS: '/api/status',
  CONFIG: '/api/config',
} as const
