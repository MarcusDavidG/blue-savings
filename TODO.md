# BlueSavings - Technical Task List

**GitHub**: https://github.com/MarcusDavidG/blue-savings  
**Last Updated**: 2026-01-07

> **Workflow**: For each task, create a GitHub issue and feature branch. Work on the branch, then raise a PR that closes the issue.

---

## 📊 Current State

### ✅ Completed
- [x] Set up Foundry project structure
- [x] Write SavingsVault.sol smart contract
- [x] Write comprehensive test suite (18 tests, 100% passing)
- [x] Create deployment scripts (Deploy.s.sol, Interact.s.sol)
- [x] Write README.md documentation
- [x] Write DEPLOYMENT_GUIDE.md
- [x] Write NEXT_STEPS.md action plan
- [x] Rebrand to BlueSavings
- [x] Push to GitHub (6 commits)

### 🚧 Current Status
- **Contract Status**: Not deployed
- **Branch**: master
- **Test Coverage**: 18 tests passing
- **Contract Size**: ~217 lines

---

## 🎯 Deployment Tasks (User Managed)

> **Note**: These require terminal commands. User will handle deployment.

### Pre-Deployment Setup
```bash
# 1. Set up environment
cd ~/blue-savings
cp .env.example .env
nano .env  # Add PRIVATE_KEY and BASESCAN_API_KEY

# 2. Get test ETH
# Visit: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
```

### Testnet Deployment (Base Sepolia)
```bash
# Run tests first
forge test -vv

# Deploy to Sepolia
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base_sepolia \
  --broadcast \
  --verify

# Note the deployed address!
```

### Mainnet Deployment (Base)
```bash
# Deploy to Base mainnet
forge script script/Deploy.s.sol:DeployScript \
  --rpc-url base \
  --broadcast \
  --verify

# Save contract address
echo "VAULT_ADDRESS=0x..." >> .env
```

### Post-Deployment
- [ ] User will create issue to update README with contract address
- [ ] User will test contract interactions on-chain

---

## 🔧 Technical Backlog (Development Tasks)

### High Priority - Week 1

#### Issue #1: Add GitHub Issue Templates
**Branch**: `feature/github-templates`
**Files to create**:
- `.github/ISSUE_TEMPLATE/bug_report.md`
- `.github/ISSUE_TEMPLATE/feature_request.md`
- `.github/PULL_REQUEST_TEMPLATE.md`

#### Issue #2: Add Vault Metadata Feature
**Branch**: `feature/vault-metadata`
**Changes**:
- Add `metadata` field to Vault struct (string)
- Update `createVault()` to accept metadata parameter
- Add `setVaultMetadata()` function
- Update tests
- Update deployment scripts

#### Issue #3: Gas Optimization Pass
**Branch**: `optimization/gas-improvements`
**Focus**:
- Review storage patterns
- Optimize loops if any
- Pack struct variables efficiently
- Add gas report to CI
- Document gas costs

#### Issue #4: Add CONTRIBUTING.md
**Branch**: `docs/contributing-guide`
**Content**:
- Development setup instructions
- Branching strategy
- PR guidelines
- Testing requirements
- Code style guide

#### Issue #5: Enhanced Event Emissions
**Branch**: `feature/enhanced-events`
**Changes**:
- Add indexed parameters for better filtering
- Add VaultMetadataUpdated event
- Add comprehensive event docs
- Update tests to verify events

---

### Medium Priority - Week 2

#### Issue #6: ERC-20 Token Support
**Branch**: `feature/erc20-support`
**Changes**:
- Add ERC20 interface imports
- Modify Vault struct to support token address
- Update deposit/withdraw for ERC20
- Add token allowance checks
- Support both ETH and ERC20 (USDC, DAI, USDT on Base)
- Comprehensive tests for token vaults
- Update scripts for token interactions

**Sub-tasks**:
- [ ] Design token vault architecture
- [ ] Implement token deposit logic
- [ ] Implement token withdrawal logic
- [ ] Add token balance tracking
- [ ] Test with mock ERC20
- [ ] Test with Base testnet tokens
- [ ] Update documentation

#### Issue #7: Vault Templates System
**Branch**: `feature/vault-templates`
**Changes**:
- Create VaultTemplate struct
- Add template registry
- Predefined templates (30-day, 90-day, 1-year, goal-based)
- Function to create vault from template
- Tests for template system
- Update deployment scripts

#### Issue #8: Emergency Pause Mechanism
**Branch**: `feature/emergency-pause`
**Changes**:
- Add Pausable functionality
- Owner can pause/unpause contract
- Deposits/withdrawals blocked when paused
- Emergency withdrawals still work
- Add tests for pause scenarios
- Update documentation

#### Issue #9: Batch Operations Support
**Branch**: `feature/batch-operations`
**Changes**:
- Add batchCreateVaults function
- Add batchDeposit function
- Gas optimization for batch ops
- Tests for batch operations
- Update scripts

### Code Quality & Infrastructure

#### Issue #10: Add CI/CD Pipeline
**Branch**: `ci/github-actions`
**Files**:
- `.github/workflows/test.yml` - Run tests on PR
- `.github/workflows/lint.yml` - Solidity linting
- `.github/workflows/coverage.yml` - Coverage reports

#### Issue #11: Add Solidity Coverage
**Branch**: `test/coverage-setup`
**Changes**:
- Configure forge coverage
- Add coverage badge to README
- Set coverage thresholds
- Document uncovered areas

#### Issue #12: Add NatSpec Documentation
**Branch**: `docs/natspec`
**Changes**:
- Add comprehensive NatSpec to all functions
- Document all events and errors
- Add contract-level documentation
- Generate docs with forge doc

---

### Advanced Features - Week 3

#### Issue #13: Yield Integration (Aave on Base)
**Branch**: `feature/yield-integration`
**Changes**:
- Research Aave V3 on Base
- Add yield strategy contracts
- Optional yield generation for vaults
- Yield claiming mechanism
- Comprehensive tests
- Update documentation

#### Issue #14: Referral System
**Branch**: `feature/referral-system`
**Changes**:
- Add referral tracking
- Referral code generation
- Referral rewards (fee sharing)
- ReferralManager contract
- Tests for referral logic
- Update scripts

#### Issue #15: Multi-Signature Vault Support
**Branch**: `feature/multisig-vaults`
**Changes**:
- Add multi-owner vault type
- Signature threshold logic
- Approval workflow for withdrawals
- Tests for multisig scenarios
- Update documentation

#### Issue #16: NFT Vault Receipts
**Branch**: `feature/nft-receipts`
**Changes**:
- ERC-721 receipt tokens
- Mint on vault creation
- Burn on vault closure
- Metadata with vault details
- Tests for NFT functionality

---

### Performance & Security

#### Issue #17: Security Audit Preparation
**Branch**: `security/audit-prep`
**Tasks**:
- Add comprehensive inline comments
- Document all assumptions
- Add security considerations to README
- Create SECURITY.md
- List known limitations
- Prepare audit checklist

#### Issue #18: Formal Verification Setup
**Branch**: `test/formal-verification`
**Tasks**:
- Add Certora specs (if applicable)
- Property-based testing with Foundry
- Invariant tests
- Document verification results

#### Issue #19: Gas Profiling & Benchmarking
**Branch**: `optimization/gas-profiling`
**Tasks**:
- Profile all functions
- Create gas benchmarks
- Compare with similar protocols
- Document optimization opportunities
- Add gas usage to documentation

---

## 🧪 Testing Enhancements

### Issue #20: Fuzz Testing Expansion
**Branch**: `test/fuzz-testing`
**Changes**:
- Add more fuzz test scenarios
- Test edge cases with fuzzing
- Increase fuzz runs
- Document findings

### Issue #21: Integration Tests
**Branch**: `test/integration-tests`
**Changes**:
- Fork Base mainnet for tests
- Test with real protocols (Aave, etc.)
- Test with actual Base tokens
- End-to-end scenarios

### Issue #22: Test Coverage to 100%
**Branch**: `test/full-coverage`
**Tasks**:
- Identify uncovered lines
- Add tests for edge cases
- Test all revert scenarios
- Test all events
- Achieve 100% line coverage

---

## 📚 Documentation Tasks

### Issue #23: API Reference Documentation
**Branch**: `docs/api-reference`
**Content**:
- Complete function reference
- Parameter descriptions
- Return value documentation
- Usage examples for each function
- Error handling guide

### Issue #24: Architecture Documentation
**Branch**: `docs/architecture`
**Content**:
- System architecture diagrams
- Contract interaction flows
- State machine diagrams
- Security model documentation
- Upgrade patterns (if applicable)

### Issue #25: Developer Guides
**Branch**: `docs/developer-guides`
**Content**:
- Getting started guide
- Testing guide
- Deployment guide
- Integration guide
- Troubleshooting guide

---

## 🛠️ Tooling & Scripts

### Issue #26: Deployment Verification Script
**Branch**: `scripts/deployment-verification`
**Content**:
- Script to verify deployment
- Check contract state post-deployment
- Validate configuration
- Test basic interactions

### Issue #27: Contract Interaction CLI
**Branch**: `scripts/cli-tool`
**Content**:
- Interactive CLI for contract operations
- User-friendly commands
- Help documentation
- Error handling

### Issue #28: Analytics Dashboard Script
**Branch**: `scripts/analytics`
**Content**:
- Script to query contract stats
- Vault analytics
- Fee analytics
- User statistics
- Export to CSV/JSON

---

## 🔄 Workflow Guidelines

### Creating an Issue
1. Go to GitHub Issues
2. Use template if applicable
3. Clear title and description
4. Add labels (bug, enhancement, documentation, etc.)
5. Assign to yourself

### Working on a Task
```bash
# 1. Create branch from master
git checkout master
git pull origin master
git checkout -b feature/your-feature-name

# 2. Make changes and commit
git add .
git commit -m "feat: add feature description"

# 3. Run tests
forge test -vv

# 4. Push branch
git push -u origin feature/your-feature-name

# 5. Create PR on GitHub
# - Reference issue in description (e.g., "Closes #1")
# - Request review if needed
# - Merge when approved
```

### PR Guidelines
- Clear title describing changes
- Description with context
- Include "Closes #X" to auto-close issue
- All tests must pass
- Code should be documented
- Gas impact noted if applicable

---

## 📊 Progress Tracking

### Week 1 Focus
- [ ] GitHub templates (#1)
- [ ] Vault metadata (#2)
- [ ] Gas optimization (#3)
- [ ] Contributing guide (#4)
- [ ] Enhanced events (#5)

### Week 2 Focus
- [ ] ERC-20 support (#6)
- [ ] Vault templates (#7)
- [ ] CI/CD setup (#10)
- [ ] Coverage (#11)

### Week 3 Focus
- [ ] Advanced feature (pick 1: #13, #14, #15, or #16)
- [ ] Security prep (#17)
- [ ] Integration tests (#21)

### Week 4 Focus
- [ ] Documentation polish (#23, #24, #25)
- [ ] Final optimizations
- [ ] Audit preparation

---

## 📝 Notes

### Deployment Info
- **Contract Address (Sepolia)**: _TBD (user will deploy)_
- **Contract Address (Mainnet)**: _TBD (user will deploy)_
- **Deployment Date**: _TBD_

### Development Environment
- Solidity: 0.8.24
- Framework: Foundry
- Network: Base (Chain ID: 8453)
- Testnet: Base Sepolia (Chain ID: 84532)

---

**Last Updated**: 2026-01-07  
**Next Review**: After first deployment
