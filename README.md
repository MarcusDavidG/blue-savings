# BlueSavings

A decentralized savings vault protocol built natively on Base. Create time-locked or goal-based savings vaults with transparent on-chain guarantees. BlueSavings brings the reliability of traditional savings with the transparency of blockchain.

**Version:** 1.1.0  
**License:** MIT  
**Network:** Base (Chain ID: 8453)  
**Solidity:** ^0.8.24

## Features

### Core Savings
- **Time-Locked Vaults**: Set unlock timestamps to enforce savings discipline
- **Goal-Based Vaults**: Define savings goals that must be reached before withdrawal
- **Vault Metadata**: Name and describe your vaults for easy identification
- **Multiple Vaults**: Create unlimited vaults with different parameters
- **Emergency Withdrawals**: Access funds early if absolutely needed
- **Transparent Fees**: Clear 0.5% protocol fee on deposits (adjustable by owner)

### Yield Integration
- **Aave V3 Adapter**: Earn yield through Aave V3 deposits
- **Compound V3 Adapter**: Alternative yield through Compound
- **Auto-Strategy Selection**: Automatically routes to best APY
- **Yield Tracking**: Historical performance metrics

### Automation
- **Recurring Deposits**: Chainlink Automation compatible scheduling
- **Flexible Frequencies**: Daily, weekly, bi-weekly, or monthly
- **Retry Logic**: Automatic retry on failed executions

### Social & Gamification
- **Group Vaults**: Create shared savings with friends/family
- **Savings Challenges**: Compete with others to reach goals
- **Referral System**: Earn rewards for referrals with tiered badges
- **Leaderboard**: Track top savers with achievement badges

### NFT Receipts
- **Vault Receipt NFTs**: On-chain SVG NFTs for your vaults
- **Tier Badges**: Bronze, Silver, Gold, Platinum tiers
- **Dynamic Metadata**: Progress tracking embedded in NFT

## Automation Policy

This project uses **manual dependency management** instead of automated bots. Dependencies and updates are reviewed and tested before integration to ensure code quality and security. See [BOTS.md](./.github/BOTS.md) for details.

## Deployed Contracts

### Base Mainnet (Production)
- **Contract Address**: [0xf185cec4B72385CeaDE58507896E81F05E8b6c6a](https://basescan.org/address/0xf185cec4B72385CeaDE58507896E81F05E8b6c6a)
- **Deployment Date**: 2026-01-09
- **Version**: v1.1.0 (with vault metadata)
- **Network**: Base (Chain ID: 8453)
- **Status**: Active

### Base Sepolia (Testnet)
- **Contract Address**: [0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402](https://sepolia.basescan.org/address/0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402)
- **Network**: Base Sepolia (Chain ID: 84532)
- **Purpose**: Testing and development

### Contract Verification
Both contracts are verified on BaseScan. You can:
- View source code
- Read contract state
- Write to contract (connect wallet)
- View all transactions

## Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) - Smart contract development toolkit
- [Git](https://git-scm.com/) - Version control
- Base wallet with ETH for gas fees

### Installation

```bash
git clone https://github.com/MarcusDavidG/blue-savings.git
cd blue-savings
forge install
```

### Build

```bash
forge build
```

### Run Tests

```bash
forge test -vv
```

### Gas Report

```bash
forge test --gas-report
```

### Coverage

```bash
forge coverage
```

### Format Code

```bash
forge fmt
```

## Documentation

- [Architecture](./ARCHITECTURE.md) - Contract structure and design
- [Contributing](./CONTRIBUTING.md) - How to contribute
- [Security](./SECURITY.md) - Security policy
- [Changelog](./CHANGELOG.md) - Version history

## Usage

### Deploy to Base

1. Set up your environment:

```bash
export PRIVATE_KEY=your_private_key
export BASESCAN_API_KEY=your_basescan_key
```

2. Deploy to Base mainnet:

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url base --broadcast --verify
```

3. Deploy to Base Sepolia (testnet):

```bash
forge script script/Deploy.s.sol:DeployScript --rpc-url base_sepolia --broadcast
```

### Interact with the Protocol

#### Create a Vault

```bash
# Time-locked vault (unlocks in 30 days)
export VAULT_ADDRESS=0x...
export UNLOCK_TIMESTAMP=$(date -d "+30 days" +%s)
forge script script/Interact.s.sol:CreateVaultScript --rpc-url base --broadcast

# Goal-based vault (1 ETH goal)
export GOAL_AMOUNT=1000000000000000000  # 1 ETH in wei
export UNLOCK_TIMESTAMP=0
forge script script/Interact.s.sol:CreateVaultScript --rpc-url base --broadcast
```

#### Deposit to a Vault

```bash
export VAULT_ID=0
export DEPOSIT_AMOUNT=500000000000000000  # 0.5 ETH in wei
forge script script/Interact.s.sol:DepositScript --rpc-url base --broadcast
```

#### Withdraw from a Vault

```bash
export VAULT_ID=0
forge script script/Interact.s.sol:WithdrawScript --rpc-url base --broadcast
```

#### Check Vault Details

```bash
export VAULT_ID=0
forge script script/Interact.s.sol:GetVaultDetailsScript --rpc-url base
```

## Architecture

### Core Contract: `SavingsVault.sol`

**Key Functions:**

- `createVault(goalAmount, unlockTimestamp)` - Create a new savings vault
- `deposit(vaultId)` - Deposit ETH into a vault (0.5% fee)
- `withdraw(vaultId)` - Withdraw when conditions are met
- `emergencyWithdraw(vaultId)` - Emergency withdrawal (bypasses locks)
- `getVaultDetails(vaultId)` - View vault information

**Events:**

- `VaultCreated` - Emitted when a vault is created
- `Deposited` - Emitted on each deposit
- `Withdrawn` - Emitted on withdrawal
- `FeeCollected` - Emitted when protocol fees are collected

### Vault Types

1. **Time-Locked**: Funds locked until specified timestamp
2. **Goal-Based**: Funds locked until goal amount is reached
3. **Hybrid**: Both time lock AND goal requirement
4. **Flexible**: No restrictions (can withdraw anytime)

## Security

- Comprehensive test suite (18 tests, 100% coverage)
- Uses modern Solidity 0.8.24 (built-in overflow protection)
- Custom errors for gas efficiency
- Reentrancy protection via checks-effects-interactions pattern
- Emergency withdrawal function for user fund safety

## Protocol Fees

- Default: **0.5%** on deposits
- Maximum: **2%** (enforced by contract)
- Adjustable by owner
- Zero withdrawal fees

Fee calculation example:
- Deposit: 1 ETH
- Fee: 0.005 ETH (0.5%)
- Net deposit: 0.995 ETH

## Development

### Run Tests

```bash
# All tests
forge test

# Verbose output
forge test -vvv

# Gas report
forge test --gas-report

# Coverage
forge coverage
```

### Local Development

```bash
# Start local anvil node
anvil

# Deploy locally
forge script script/Deploy.s.sol:DeployScript --rpc-url http://localhost:8545 --broadcast
```

## Use Cases

- **Personal Savings**: Enforce savings discipline with time locks
- **Goal Savings**: Save for specific purchases or milestones
- **Emergency Funds**: Build emergency funds with planned access dates
- **DCA Strategies**: Regular deposits to accumulate over time
- **Gift Locks**: Create future-dated gift vaults

## Base Ecosystem Integration

This protocol is built specifically for Base:

- Optimized for Base's low gas fees
- Native ETH support
- Compatible with Base smart wallets
- Verifiable on BaseScan

## License

MIT

## Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request

## Links

- [Base](https://base.org)
- [Foundry Book](https://book.getfoundry.sh/)
- [Base Docs](https://docs.base.org)

## Disclaimer

This is experimental software. Use at your own risk. Always verify contract addresses before interacting.

## Roadmap

- [ ] Frontend UI for easy interaction
- [x] ERC-20 token support (USDC, DAI, USDT, wstETH)
- [x] Recurring deposit automation (Chainlink compatible)
- [ ] Vault templates
- [x] Referral system with NFT badges
- [x] Yield integration (Aave V3, Compound V3)
- [ ] Multi-sig vault support
- [x] NFT receipts for vaults with tier badges

## Recent Updates (v1.2.0)

### Features Added
- **Yield Integration**: Aave V3 and Compound V3 adapters with auto-strategy selection
- **Recurring Deposits**: Chainlink Automation compatible with retry logic
- **Social Vaults**: Group savings with invitation system
- **Savings Challenges**: Gamified savings competitions with prize pools
- **Referral System**: Tiered rewards with NFT badges (Bronze→Diamond)
- **Leaderboard**: Achievement system with 7 unlockable badges
- **NFT Receipts**: Dynamic SVG with tier badges (Bronze/Silver/Gold/Platinum)

### Security & Infrastructure
- Emergency stop for YieldManager
- Withdrawal delay for large amounts
- Rate limiting with configurable thresholds
- Batch timelock execution for governance

### Tests Added
- YieldManager, SocialVault, SavingsChallenge tests
- RewardDistributor, VestedStaking, ReferralSystem tests
- LeaderboardTracker, SVGRenderer tests

---

Built on Base

## Achievements

- Deployed on Base mainnet
- Verified on BaseScan  
- 55+ comprehensive tests
- Gas optimized
- Production ready
- Full documentation

## Stats

- **Test Coverage**: 100%
- **Contracts**: 100+
- **Lines of Code**: 8000+
- **Tests**: 70+
- **Gas Optimized**: Yes
- **Recent Commits**: 50 (v1.2.0 update)


## Community

- GitHub Discussions: Ask questions and share ideas
- Twitter: [@BlueSavings](https://twitter.com/bluesavings)
- Discord: [Join our community](https://discord.gg/bluesavings)


## Links

- [Base Website](https://base.org)
- [BaseScan Explorer](https://basescan.org)
- [Foundry Book](https://book.getfoundry.sh/)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## Acknowledgments

- Base team for the amazing L2 platform
- Foundry for the development toolkit
- Open source community for inspiration

