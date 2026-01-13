export const errorMessages = {
  WALLET_NOT_CONNECTED: 'Please connect your wallet',
  WRONG_NETWORK: 'Please switch to Base network',
  INSUFFICIENT_BALANCE: 'Insufficient balance',
  USER_REJECTED: 'Transaction rejected by user',
  TRANSACTION_FAILED: 'Transaction failed',
  CONTRACT_ERROR: 'Contract interaction failed',
  NETWORK_ERROR: 'Network error occurred',
}

export const errorHandlers = {
  handleWalletError: (error: Error) => {
    console.error('Wallet error:', error)
    return error.message || errorMessages.CONTRACT_ERROR
  },
  handleTransactionError: (error: Error) => {
    console.error('Transaction error:', error)
    if (error.message.includes('user rejected')) {
      return errorMessages.USER_REJECTED
    }
    return errorMessages.TRANSACTION_FAILED
  },
  handleNetworkError: (error: Error) => {
    console.error('Network error:', error)
    return errorMessages.NETWORK_ERROR
  },
}
