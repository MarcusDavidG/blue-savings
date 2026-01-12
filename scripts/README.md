# Scripts Directory

Helper scripts for interacting with BlueSavings contract.

## Mainnet Scripts

### Core Operations

- `create-vault-mainnet.sh` - Create custom vault
- `deposit-mainnet.sh` - Deposit to existing vault
- `check-vault-mainnet.sh` - Check vault details

### Templates

- `create-emergency-fund.sh` - Emergency fund (6mo lock, 5 ETH goal)
- `create-vacation-fund.sh` - Vacation savings (1yr lock, 2 ETH goal)
- `create-flexible-savings.sh` - No restrictions

## Usage Examples

### Create Custom Vault
```bash
export METADATA="My Custom Vault"
export GOAL_AMOUNT=3000000000000000000  # 3 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 7776000))  # 90 days
./scripts/create-vault-mainnet.sh
```

### Deposit to Vault
```bash
export VAULT_ID=0
export DEPOSIT_AMOUNT=500000000000000000  # 0.5 ETH
./scripts/deposit-mainnet.sh
```

### Check Vault
```bash
export VAULT_ID=0
./scripts/check-vault-mainnet.sh
```

## Prerequisites

1. Configure `.env` with `PRIVATE_KEY` and `VAULT_ADDRESS`
2. Have ETH on Base mainnet for gas
3. Foundry installed

## Notes

- All amounts in wei (1 ETH = 1000000000000000000 wei)
- Timestamps in Unix format
- 0.5% protocol fee on all deposits
