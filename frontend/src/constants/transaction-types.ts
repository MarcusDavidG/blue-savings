export const TRANSACTION_TYPES = {
  CREATE_VAULT: 'create',
  DEPOSIT: 'deposit',
  WITHDRAW: 'withdraw',
  EMERGENCY_WITHDRAW: 'emergency',
  SET_METADATA: 'metadata',
} as const

export type TransactionType = typeof TRANSACTION_TYPES[keyof typeof TRANSACTION_TYPES]
