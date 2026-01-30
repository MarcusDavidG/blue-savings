# BlueSavings Mainnet Deployment Instructions

## Overview

Deploy 10 contracts to Base mainnet with verification on BaseScan.

**Network**: Base Mainnet (Chain ID: 8453)  
**RPC**: https://mainnet.base.org

## Prerequisites

Ensure your `.env` file contains:
```bash
PRIVATE_KEY=<your_deployer_private_key>
BASESCAN_API_KEY=<your_basescan_api_key>
```

Verify sufficient ETH balance for gas fees (~0.01-0.02 ETH per contract).

---

## Contracts to Deploy

### Phase 1: Core Infrastructure (No Dependencies)

| # | Contract | Constructor Args | Deployment Command |
|---|----------|------------------|-------------------|
| 1 | SocialVault | None | `forge create src/social/SocialVault.sol:SocialVault --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 2 | SavingsChallenge | None | `forge create src/challenges/SavingsChallenge.sol:SavingsChallenge --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 3 | LeaderboardTracker | None | `forge create src/analytics/LeaderboardTracker.sol:LeaderboardTracker --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 4 | MultiSigVault | None | `forge create src/multisig/MultiSigVault.sol:MultiSigVault --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 5 | VaultDelegation | None | `forge create src/delegation/VaultDelegation.sol:VaultDelegation --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 6 | ChainlinkPriceFeed | None | `forge create src/oracle/ChainlinkPriceFeed.sol:ChainlinkPriceFeed --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 7 | VaultSnapshot | None | `forge create src/snapshot/VaultSnapshot.sol:VaultSnapshot --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |
| 8 | ContractRegistry | None | `forge create src/registry/ContractRegistry.sol:ContractRegistry --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify` |

### Phase 2: Contracts with Dependencies

| # | Contract | Constructor Args | Notes |
|---|----------|------------------|-------|
| 9 | YieldManager | `address _vault` | Use existing TokenSavingsVault: `0xf185cec4B72385CeaDE58507896E81F05E8b6c6a` |
| 10 | VaultFactory | `address _implementation` | Use existing SavingsVault or TokenSavingsVault address |

**YieldManager Deployment:**
```bash
forge create src/yield/YieldManager.sol:YieldManager \
  --rpc-url base \
  --private-key $PRIVATE_KEY \
  --constructor-args 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a \
  --broadcast \
  --verify
```

**VaultFactory Deployment:**
```bash
forge create src/factory/VaultFactory.sol:VaultFactory \
  --rpc-url base \
  --private-key $PRIVATE_KEY \
  --constructor-args 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a \
  --broadcast \
  --verify
```

---

## Verification (if auto-verify fails)

If automatic verification fails, manually verify:

```bash
forge verify-contract <DEPLOYED_ADDRESS> <ContractName> \
  --chain base \
  --watch
```

For contracts with constructor args:
```bash
forge verify-contract <DEPLOYED_ADDRESS> YieldManager \
  --chain base \
  --constructor-args $(cast abi-encode "constructor(address)" 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a) \
  --watch
```

---

## Post-Deployment Checklist

After each deployment:
1. [ ] Record the deployed contract address
2. [ ] Verify contract on BaseScan
3. [ ] Test read functions on BaseScan
4. [ ] Register contract in ContractRegistry (after it's deployed)

---

## Contract Address Recording

Fill in addresses after deployment:

| Contract | Address | Verified | Tx Hash |
|----------|---------|----------|---------|
| SocialVault | | [ ] | |
| SavingsChallenge | | [ ] | |
| LeaderboardTracker | | [ ] | |
| MultiSigVault | | [ ] | |
| VaultDelegation | | [ ] | |
| ChainlinkPriceFeed | | [ ] | |
| VaultSnapshot | | [ ] | |
| ContractRegistry | | [ ] | |
| YieldManager | | [ ] | |
| VaultFactory | | [ ] | |

---

## Register Contracts in Registry

After deploying ContractRegistry, register all contracts:

```bash
cast send <REGISTRY_ADDRESS> "registerContract(bytes32,address)" \
  $(cast --format-bytes32-string "SocialVault") <SOCIAL_VAULT_ADDRESS> \
  --rpc-url base \
  --private-key $PRIVATE_KEY
```

Repeat for each contract with its identifier.

---

## Estimated Gas Costs

| Contract | Estimated Gas | ~Cost (at 0.001 gwei) |
|----------|---------------|----------------------|
| SocialVault | ~1,500,000 | ~0.0015 ETH |
| SavingsChallenge | ~1,800,000 | ~0.0018 ETH |
| LeaderboardTracker | ~1,200,000 | ~0.0012 ETH |
| MultiSigVault | ~2,500,000 | ~0.0025 ETH |
| VaultDelegation | ~500,000 | ~0.0005 ETH |
| ChainlinkPriceFeed | ~800,000 | ~0.0008 ETH |
| VaultSnapshot | ~900,000 | ~0.0009 ETH |
| ContractRegistry | ~700,000 | ~0.0007 ETH |
| YieldManager | ~2,000,000 | ~0.002 ETH |
| VaultFactory | ~1,200,000 | ~0.0012 ETH |
| **Total** | ~13,100,000 | **~0.013 ETH** |

*Note: Actual costs may vary based on network conditions.*

---

## Troubleshooting

### "Insufficient funds"
- Ensure deployer wallet has enough ETH for gas

### "Verification failed"
- Wait a few blocks and retry manual verification
- Check BASESCAN_API_KEY is correct

### "Nonce too low"
- Wait for pending transactions to confirm
- Or use `--nonce <correct_nonce>` flag

### "Contract creation code storage out of gas"
- Increase gas limit: `--gas-limit 5000000`

---

## Security Notes

- Double-check all addresses before deployment
- Deployer address becomes contract owner
- Keep deployment records for audit trail
- Test on Base Sepolia first if unsure
