export const EVENT_NAMES = {
  WALLET_CONNECTED: 'wallet:connected',
  WALLET_DISCONNECTED: 'wallet:disconnected',
  NETWORK_CHANGED: 'network:changed',
  VAULT_CREATED: 'vault:created',
  DEPOSIT_SUCCESS: 'deposit:success',
  WITHDRAW_SUCCESS: 'withdraw:success',
  TRANSACTION_PENDING: 'transaction:pending',
  TRANSACTION_CONFIRMED: 'transaction:confirmed',
  TRANSACTION_FAILED: 'transaction:failed',
} as const
