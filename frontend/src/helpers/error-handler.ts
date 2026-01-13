export class ContractError extends Error {
  constructor(message: string, public code?: string) {
    super(message)
    this.name = 'ContractError'
  }
}

export function handleContractError(error: any): string {
  if (error?.message?.includes('user rejected')) {
    return 'Transaction rejected by user'
  }
  if (error?.message?.includes('insufficient funds')) {
    return 'Insufficient funds for transaction'
  }
  return error?.message || 'Transaction failed'
}
