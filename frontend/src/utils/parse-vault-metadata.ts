import { VaultMetadata } from '@/types/vault-types'

export function parseVaultMetadata(metadata: string): VaultMetadata {
  try {
    return JSON.parse(metadata)
  } catch {
    return { name: 'Unnamed Vault', description: '' }
  }
}

export function stringifyVaultMetadata(metadata: VaultMetadata): string {
  return JSON.stringify(metadata)
}
