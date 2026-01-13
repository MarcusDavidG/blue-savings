export interface CreateVaultForm {
  unlockTime: number
  goal: string
  name: string
  description: string
}

export interface DepositForm {
  vaultId: string
  amount: string
}

export interface WithdrawForm {
  vaultId: string
}
