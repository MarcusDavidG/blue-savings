# On-Chain Activity Guide

This guide walks through generating on-chain activity for BlueSavings on Base mainnet.

## Prerequisites

1. ETH on Base mainnet for gas fees
2. `.env` file configured with `PRIVATE_KEY` and `VAULT_ADDRESS`
3. Foundry installed

## Step 1: Create Your First Vault

### Quick Method
```bash
export METADATA="My First Savings Vault"
export GOAL_AMOUNT=1000000000000000000  # 1 ETH goal
export UNLOCK_TIMESTAMP=0  # No time lock

./scripts/create-vault-mainnet.sh
```

### Manual Method
```bash
forge script script/Interact.s.sol:CreateVaultScript \
  --rpc-url base \
  --broadcast \
  -vvv
```

## Step 2: Make Deposits

```bash
export VAULT_ID=0
export DEPOSIT_AMOUNT=100000000000000000  # 0.1 ETH

./scripts/deposit-mainnet.sh
```

## Step 3: Check Vault Status

```bash
export VAULT_ID=0
./scripts/check-vault-mainnet.sh
```

## Example Vault Configurations

### Emergency Fund (6 month lock)
```bash
export METADATA="Emergency Fund"
export GOAL_AMOUNT=5000000000000000000  # 5 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 15768000))  # 6 months
```

### Vacation Savings (1 year, 2 ETH goal)
```bash
export METADATA="Summer Vacation 2027"
export GOAL_AMOUNT=2000000000000000000  # 2 ETH
export UNLOCK_TIMESTAMP=$(($(date +%s) + 31536000))  # 1 year
```

### House Down Payment (no time lock, high goal)
```bash
export METADATA="House Down Payment"
export GOAL_AMOUNT=50000000000000000000  # 50 ETH
export UNLOCK_TIMESTAMP=0
```

## Tracking Your Activity

All transactions will appear on:
- [BaseScan Contract](https://basescan.org/address/0xf185cec4B72385CeaDE58507896E81F05E8b6c6a)
- [Talent.app Profile](https://talent.app/~/earn/base-january)

## Protocol Fees

- **Fee Rate:** 0.5% (50 basis points)
- **Example:** Deposit 1 ETH → 0.995 ETH to vault, 0.005 ETH to protocol
- **Fees Benefit:** Competition ranking on Talent.app

## Tips for Maximum Impact

1. **Multiple small deposits** > One large deposit (more transactions)
2. **Create diverse vaults** (time-locked, goal-based, flexible)
3. **Document everything** for showcase
4. **Share on social media** for visibility
