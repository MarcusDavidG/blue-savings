export interface VaultData {
  id: bigint
  owner: string
  balance: bigint
  unlockTime: bigint
  goal: bigint
  metadata: string
  createdAt: bigint
}

export interface VaultMetadata {
  name: string
  description: string
  category?: string
}

export type VaultStatus = 'active' | 'locked' | 'unlocked' | 'completed'
