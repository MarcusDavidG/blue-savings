export interface TransactionData {
  hash: string
  from: string
  to: string
  value: bigint
  timestamp: number
  status: 'pending' | 'success' | 'failed'
  type: 'deposit' | 'withdraw' | 'create' | 'emergency'
}

export interface TransactionReceipt {
  hash: string
  blockNumber: bigint
  gasUsed: bigint
  status: 'success' | 'reverted'
}
