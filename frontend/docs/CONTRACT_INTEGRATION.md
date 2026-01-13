# Contract Integration Guide

## Contract Address

- **Base Mainnet**: `0xf185cec4B72385CeaDE58507896E81F05E8b6c6a`
- **Base Sepolia**: `0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402`

## Usage

```tsx
import { useCreateVault, useDeposit } from '@/hooks/contract'

function MyComponent() {
  const { createVault } = useCreateVault()
  const { deposit } = useDeposit(vaultId, amount)
  
  return <button onClick={createVault}>Create Vault</button>
}
```

## Available Hooks

- `useCreateVault()` - Create new vault
- `useDeposit()` - Deposit to vault
- `useWithdraw()` - Withdraw from vault
- `useVaultDetails()` - Get vault information
