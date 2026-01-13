# Custom Hooks Guide

## Wallet Hooks

### useWallet()
Access wallet connection state and functions.

```tsx
const { address, isConnected, connect, disconnect } = useWallet()
```

### useBalance()
Get wallet balance.

```tsx
const { balance, isLoading } = useBalance()
```

## Contract Hooks

### useCreateVault()
Create a new savings vault.

```tsx
const { createVault, isLoading, isSuccess } = useCreateVault()
```

### useDeposit()
Deposit ETH to a vault.

```tsx
const { deposit, isLoading } = useDeposit(vaultId, amount)
```

### useWithdraw()
Withdraw from a vault.

```tsx
const { withdraw, isLoading } = useWithdraw(vaultId)
```

### useVaultDetails()
Get vault information.

```tsx
const { vaultDetails, isLoading } = useVaultDetails(vaultId)
```
