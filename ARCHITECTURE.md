# BlueSavings Architecture

## Contract Structure

```
SavingsVault
├── Vault struct
├── State variables  
├── Events
├── Errors
├── Modifiers
└── Functions
    ├── External (user-facing)
    └── View (read-only)
```

## Key Features

1. **Vault Creation**: Users create vaults with time/goal locks
2. **Deposits**: ETH deposits with protocol fees
3. **Withdrawals**: Conditional based on lock status
4. **Metadata**: Name/describe vaults
5. **Statistics**: 19 helper functions for tracking

## Storage Layout

- `vaultCounter`: Increments for each new vault
- `vaults`: mapping(uint256 => Vault)
- `userVaults`: mapping(address => uint256[])
- `feeBps`: Protocol fee in basis points
- `totalFeesCollected`: Accumulated fees

## Gas Optimizations

- Storage variable caching
- Unchecked math for safe operations
- Minimal SLOAD operations

