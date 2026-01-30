# Gemini Agent Deployment Prompt

## Task: Deploy BlueSavings Contracts to Base Mainnet

You are tasked with deploying 10 smart contracts from the BlueSavings project to Base mainnet and updating the README with deployed contract addresses.

### Environment Setup

The `.env` file is already configured with:
- `PRIVATE_KEY` - Deployer wallet private key
- `BASESCAN_API_KEY` - BaseScan API key for verification

Load environment variables before starting:
```bash
source .env
```

### Deployment Order

Deploy contracts in this exact order (8 independent contracts first, then 2 with dependencies):

#### Step 1: Deploy Independent Contracts

Execute these 8 deployments. Each command deploys and verifies on BaseScan:

```bash
# 1. SocialVault
forge create src/social/SocialVault.sol:SocialVault --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 2. SavingsChallenge
forge create src/challenges/SavingsChallenge.sol:SavingsChallenge --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 3. LeaderboardTracker
forge create src/analytics/LeaderboardTracker.sol:LeaderboardTracker --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 4. MultiSigVault
forge create src/multisig/MultiSigVault.sol:MultiSigVault --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 5. VaultDelegation
forge create src/delegation/VaultDelegation.sol:VaultDelegation --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 6. ChainlinkPriceFeed
forge create src/oracle/ChainlinkPriceFeed.sol:ChainlinkPriceFeed --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 7. VaultSnapshot
forge create src/snapshot/VaultSnapshot.sol:VaultSnapshot --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify

# 8. ContractRegistry
forge create src/registry/ContractRegistry.sol:ContractRegistry --rpc-url base --private-key $PRIVATE_KEY --broadcast --verify
```

#### Step 2: Deploy Contracts with Dependencies

These contracts require constructor arguments. Use the existing TokenSavingsVault address: `0xf185cec4B72385CeaDE58507896E81F05E8b6c6a`

```bash
# 9. YieldManager (requires vault address)
forge create src/yield/YieldManager.sol:YieldManager \
  --rpc-url base \
  --private-key $PRIVATE_KEY \
  --constructor-args 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a \
  --broadcast \
  --verify

# 10. VaultFactory (requires implementation address)
forge create src/factory/VaultFactory.sol:VaultFactory \
  --rpc-url base \
  --private-key $PRIVATE_KEY \
  --constructor-args 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a \
  --broadcast \
  --verify
```

### Record Deployed Addresses

After each successful deployment, record:
1. Contract name
2. Deployed address (shown in output as `Deployed to: 0x...`)
3. Transaction hash
4. Verification status

### Manual Verification (if auto-verify fails)

If verification fails during deployment, run manually:

```bash
forge verify-contract <ADDRESS> <ContractName> --chain base --watch
```

For YieldManager/VaultFactory:
```bash
forge verify-contract <ADDRESS> YieldManager --chain base \
  --constructor-args $(cast abi-encode "constructor(address)" 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a) --watch
```

### Update README.md

After ALL deployments complete, update the `README.md` file.

Find the section `## Deployed Contracts` and add a new subsection after the existing contracts:

```markdown
### Additional Mainnet Contracts (v1.2.0)

| Contract | Address | Purpose |
|----------|---------|---------|
| SocialVault | [0x...](https://basescan.org/address/0x...) | Group savings with friends/family |
| SavingsChallenge | [0x...](https://basescan.org/address/0x...) | Gamified savings competitions |
| LeaderboardTracker | [0x...](https://basescan.org/address/0x...) | Track top savers |
| MultiSigVault | [0x...](https://basescan.org/address/0x...) | Multi-signature vault withdrawals |
| VaultDelegation | [0x...](https://basescan.org/address/0x...) | Delegate vault management |
| ChainlinkPriceFeed | [0x...](https://basescan.org/address/0x...) | Price oracle integration |
| VaultSnapshot | [0x...](https://basescan.org/address/0x...) | Historical balance snapshots |
| ContractRegistry | [0x...](https://basescan.org/address/0x...) | Protocol contract registry |
| YieldManager | [0x...](https://basescan.org/address/0x...) | Yield strategy management |
| VaultFactory | [0x...](https://basescan.org/address/0x...) | Create new vault instances |

**Deployment Date**: [INSERT_DATE]  
**Deployed By**: [DEPLOYER_ADDRESS]  
**Network**: Base Mainnet (Chain ID: 8453)
```

Replace `[0x...]` with actual deployed addresses.

### Success Criteria

- [ ] All 10 contracts deployed successfully
- [ ] All 10 contracts verified on BaseScan
- [ ] README.md updated with all contract addresses
- [ ] Addresses formatted as clickable BaseScan links

### Error Handling

**If deployment fails:**
1. Check wallet has sufficient ETH
2. Wait for any pending transactions
3. Retry the specific failed deployment

**If verification fails:**
1. Wait 30 seconds for chain indexing
2. Run manual verification command
3. Check BaseScan API key is valid

### Output Format

After completing all deployments, provide a summary:

```
DEPLOYMENT SUMMARY
==================
1. SocialVault: 0x... [VERIFIED]
2. SavingsChallenge: 0x... [VERIFIED]
3. LeaderboardTracker: 0x... [VERIFIED]
4. MultiSigVault: 0x... [VERIFIED]
5. VaultDelegation: 0x... [VERIFIED]
6. ChainlinkPriceFeed: 0x... [VERIFIED]
7. VaultSnapshot: 0x... [VERIFIED]
8. ContractRegistry: 0x... [VERIFIED]
9. YieldManager: 0x... [VERIFIED]
10. VaultFactory: 0x... [VERIFIED]

Total Gas Used: X ETH
README Updated: YES
```

---

**IMPORTANT**: Execute deployments one at a time and wait for confirmation before proceeding to the next. Do not batch deploy as this can cause nonce issues.
