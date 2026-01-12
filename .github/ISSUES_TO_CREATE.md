# GitHub Issues to Create for Today's Work

Copy each issue below and create it on GitHub at: https://github.com/MarcusDavidG/blue-savings/issues/new

---

## Issue #1

**Title:** `[FEATURE] Generate mainnet on-chain activity - Create vaults`

**Labels:** `enhancement`, `critical`

**Description:**
```markdown
## Feature Description

Create multiple vaults on Base mainnet to generate on-chain activity and protocol fees.

## Problem or Use Case

Critical for Talent.app ranking - currently have 0 on-chain transactions despite having deployed contract.

## Proposed Solution

1. Create 3-5 different vaults with various configurations
2. Document each vault creation transaction
3. Track vault IDs and configurations

## Technical Considerations

- Requires PRIVATE_KEY in .env
- Will cost gas fees
- Generates protocol activity
- Creates BaseScan transaction history

## Priority

- [x] Critical
```

---

## Issue #2

**Title:** `[FEATURE] Generate mainnet deposits and protocol fees`

**Labels:** `enhancement`, `critical`

**Description:**
```markdown
## Feature Description

Make deposits to created vaults to generate protocol fees (0.5% of deposits).

## Problem or Use Case

Need to demonstrate protocol usage and generate actual fee revenue for Talent.app competition.

## Proposed Solution

1. Deposit ETH into created vaults
2. Generate protocol fees
3. Document all transactions
4. Create metrics dashboard

## Technical Considerations

- 0.5% protocol fee per deposit
- Multiple small deposits better than one large
- Track accumulated fees
- Monitor owner balance

## Priority

- [x] Critical
```

---

## Issue #3

**Title:** `[DOCS] Document on-chain transactions and metrics`

**Labels:** `documentation`

**Description:**
```markdown
## Feature Description

Create comprehensive documentation of all on-chain activity including vault creations, deposits, and fee collection.

## Problem or Use Case

Need to track and showcase protocol usage for competition judges and future users.

## Proposed Solution

1. Create METRICS.md with transaction links
2. Add BaseScan links to README
3. Create activity dashboard mockup
4. Document gas costs

## Technical Considerations

- Update README with live stats
- Include transaction hashes
- Show fee accumulation
- Display TVL metrics

## Priority

- [x] High
```

---

## Issue #4

**Title:** `[FEATURE] Implement ERC-20 token support`

**Labels:** `enhancement`

**Description:**
```markdown
## Feature Description

Extend vaults to support ERC-20 token deposits in addition to native ETH.

## Problem or Use Case

Users want to save various tokens (USDC, DAI, etc.) not just ETH. This significantly expands protocol utility.

## Proposed Solution

1. Create separate vault type for ERC-20
2. Add token address parameter
3. Implement SafeERC20 for transfers
4. Update tests for token support
5. Add token vault examples

## Technical Considerations

- Requires SafeERC20 from OpenZeppelin
- Need approval flow documentation
- Test with multiple token types
- Gas cost implications
- Breaking change - major version bump

## Priority

- [x] High
```

---

## Issue #5

**Title:** `[FEATURE] Add batch operations functionality`

**Labels:** `enhancement`

**Description:**
```markdown
## Feature Description

Allow users to perform batch operations: create multiple vaults, deposit to multiple vaults, withdraw from multiple vaults in a single transaction.

## Problem or Use Case

Gas efficiency - users with multiple vaults want to operate on them all at once.

## Proposed Solution

1. Add batchCreateVaults function
2. Add batchDeposit function  
3. Add batchWithdraw function
4. Implement proper error handling for batch failures
5. Add events for batch operations

## Technical Considerations

- Gas optimization critical
- Need array bounds checking
- Revert behavior on partial failure
- Maximum batch size limits
- Comprehensive testing needed

## Priority

- [x] Medium
```

---

## Issue #6

**Title:** `[FEATURE] Create vault templates system`

**Labels:** `enhancement`

**Description:**
```markdown
## Feature Description

Pre-configured vault templates for common use cases (emergency fund, vacation savings, house down payment, etc.).

## Problem or Use Case

New users don't know optimal configurations. Templates make it easy to start saving.

## Proposed Solution

1. Define template struct (name, unlock time formula, goal amount suggestion)
2. Create 5-10 popular templates
3. Add createVaultFromTemplate function
4. Document each template
5. Add template examples

## Technical Considerations

- Templates stored in contract or off-chain?
- Timestamp calculations
- Goal amount recommendations
- Metadata auto-population
- Gas costs

## Priority

- [x] Medium
```

---

## Issue #7

**Title:** `[FEATURE] Add pausable functionality for emergency`

**Labels:** `enhancement`, `security`

**Description:**
```markdown
## Feature Description

Implement circuit breaker pattern - allow contract owner to pause deposits/withdrawals in case of emergency.

## Problem or Use Case

Security best practice - if vulnerability discovered, need ability to pause operations while fixing.

## Proposed Solution

1. Import OpenZeppelin Pausable
2. Add whenNotPaused modifier to critical functions
3. Add pause/unpause functions (owner only)
4. Add PauseToggled event
5. Document pause procedures

## Technical Considerations

- Emergency withdrawals should still work when paused?
- Which functions to pause vs allow
- Time-lock on pause/unpause
- Governance considerations
- Testing pause scenarios

## Priority

- [x] Medium
```

---

## Issue #8

**Title:** `[FEATURE] Implement vault transfer/delegation`

**Labels:** `enhancement`

**Description:**
```markdown
## Feature Description

Allow vault owners to transfer ownership or delegate access to their vaults.

## Problem or Use Case

Users may want to gift vaults, transfer on inheritance, or allow trusted parties to manage their savings.

## Proposed Solution

1. Add transferVault function
2. Add approveDelegate function
3. Add revokeDelegate function
4. Update access control checks
5. Add VaultTransferred event
6. Add DelegateApproved/Revoked events

## Technical Considerations

- Security critical - must verify owner
- Cannot transfer locked vaults?
- Delegate can deposit but not withdraw?
- NFT-style approval pattern
- Comprehensive security tests

## Priority

- [x] Medium
```

---

## Issue #9

**Title:** `[TEST] Add invariant tests`

**Labels:** `testing`

**Description:**
```markdown
## Feature Description

Implement property-based invariant testing to ensure contract invariants hold across all state transitions.

## Problem or Use Case

Catch edge cases and unexpected behaviors through fuzzing invariant properties.

## Proposed Solution

1. Create test/invariant/Invariants.t.sol
2. Test core invariants:
   - Total deposits = sum of all vault balances + fees
   - User vault count matches array length
   - Vault owner never changes (unless transfer feature)
   - Fee percentage within bounds
   - Locked vaults cannot be withdrawn
3. Run extensive fuzz campaigns

## Technical Considerations

- Foundry invariant testing
- Actor-based fuzzing
- Ghost variables for tracking
- Long fuzz runs (10000+ runs)
- Document invariants

## Priority

- [x] High
```

---

## Issue #10

**Title:** `[TEST] Add fuzz testing for all functions`

**Labels:** `testing`

**Description:**
```markdown
## Feature Description

Add comprehensive fuzz tests for every public function with random inputs.

## Problem or Use Case

Discover edge cases and overflow/underflow issues through randomized testing.

## Proposed Solution

1. Fuzz createVault with random parameters
2. Fuzz deposit with random amounts
3. Fuzz withdraw scenarios
4. Fuzz fee updates
5. Fuzz metadata operations
6. Target 1000+ runs per test

## Technical Considerations

- Bound inputs appropriately
- Test boundary conditions
- Test with extreme values
- Gas limits on large values
- Document assumptions

## Priority

- [x] High
```

---

## Issue #11

**Title:** `[TEST] Add integration tests`

**Labels:** `testing`

**Description:**
```markdown
## Feature Description

Create end-to-end integration tests that simulate real user workflows across multiple transactions.

## Problem or Use Case

Unit tests are great but we need to test complete user journeys and multi-step operations.

## Proposed Solution

1. Create test/integration/ directory
2. Test complete vault lifecycle
3. Test multi-user scenarios
4. Test error recovery paths
5. Test gas costs for typical workflows

## Technical Considerations

- Fork Base mainnet for testing
- Multiple users with different roles
- Time manipulation for lock testing
- Real-world gas costs
- Edge case scenarios

## Priority

- [x] High
```

---

## Issue #12

**Title:** `[TEST] Improve test coverage to 100%`

**Labels:** `testing`

**Description:**
```markdown
## Feature Description

Achieve 100% line and branch coverage for the SavingsVault contract.

## Problem or Use Case

Currently at high coverage but not 100%. Need complete confidence in all code paths.

## Proposed Solution

1. Run forge coverage
2. Identify uncovered lines
3. Add tests for missing coverage
4. Test all error conditions
5. Test all edge cases

## Technical Considerations

- Some lines may be unreachable
- Emergency paths need testing
- Owner-only functions
- Revert conditions
- Event emissions

## Priority

- [x] Medium
```

---

## Issue #13

**Title:** `[DOCS] Fill out all API documentation with code examples`

**Labels:** `documentation`

**Description:**
```markdown
## Feature Description

Add complete code examples to all API documentation files currently in docs/api/.

## Problem or Use Case

Currently have placeholder API docs. Need actual code examples for each function.

## Proposed Solution

1. Update docs/api/createVault.md with full examples
2. Update docs/api/deposit.md with examples
3. Add Solidity, JavaScript, and CLI examples
4. Include error handling examples
5. Add gas cost estimates

## Technical Considerations

- Examples must be tested and working
- Multiple language support (Solidity, JS, Python)
- Include ethers.js and viem examples
- Show both script and interactive usage
- Document common errors

## Priority

- [x] Medium
```

---

## Issue #14

**Title:** `[DOCS] Create video tutorial scripts`

**Labels:** `documentation`

**Description:**
```markdown
## Feature Description

Write scripts for video tutorials covering common BlueSavings operations.

## Problem or Use Case

Video tutorials are more engaging than text. Scripts help create consistent, professional content.

## Proposed Solution

1. Script: "Your First Vault" (5 min)
2. Script: "Time-Locked Savings" (7 min)
3. Script: "Goal-Based Saving" (7 min)
4. Script: "Advanced Features" (10 min)
5. Script: "Integration Guide" (12 min)

## Technical Considerations

- Keep scripts concise
- Include visual cues
- Show actual transactions
- Include troubleshooting
- Estimate timing

## Priority

- [x] Low
```

---

## Issue #15

**Title:** `[DOCS] Add deployment guides with screenshots`

**Labels:** `documentation`

**Description:**
```markdown
## Feature Description

Enhance deployment documentation with step-by-step screenshots and detailed explanations.

## Problem or Use Case

Current deployment docs are text-only. Screenshots make it much easier to follow.

## Proposed Solution

1. Screenshot: Setting up environment
2. Screenshot: Configuring .env
3. Screenshot: Running deployment
4. Screenshot: Verification on BaseScan
5. Screenshot: First transaction

## Technical Considerations

- Anonymize sensitive data in screenshots
- Update for both Foundry and Hardhat
- Include troubleshooting screenshots
- Mobile-friendly images
- Alt text for accessibility

## Priority

- [x] Low
```

---

## Issue #16

**Title:** `[DOCS] Write migration guides with code samples`

**Labels:** `documentation`

**Description:**
```markdown
## Feature Description

Create detailed migration guides for upgrading between contract versions.

## Problem or Use Case

When we release v2.0 with new features, users need clear migration paths.

## Proposed Solution

1. Migration guide: v1.0 to v1.1
2. Migration guide: v1.1 to v2.0
3. Code samples for data migration
4. Automated migration scripts
5. Rollback procedures

## Technical Considerations

- Data preservation
- Backward compatibility
- Gas costs of migration
- Testing migration paths
- Emergency procedures

## Priority

- [x] Low
```

---

## Issue #17

**Title:** `[DEV] Add Hardhat support alongside Foundry`

**Labels:** `enhancement`, `developer-experience`

**Description:**
```markdown
## Feature Description

Add Hardhat configuration and scripts so developers can use either Foundry or Hardhat.

## Problem or Use Case

Some developers prefer Hardhat over Foundry. Supporting both expands developer community.

## Proposed Solution

1. Add hardhat.config.js
2. Convert deploy scripts to Hardhat format
3. Add Hardhat tests (or conversion)
4. Update package.json scripts
5. Document Hardhat usage

## Technical Considerations

- Maintain both toolchains
- Keep in sync
- CI/CD for both
- Documentation for both
- Gas report compatibility

## Priority

- [x] Medium
```

---

## Issue #18

**Title:** `[DEV] Create npm package scripts`

**Labels:** `developer-experience`

**Description:**
```markdown
## Feature Description

Add comprehensive npm scripts for common development tasks.

## Problem or Use Case

Developers want simple commands like `npm test`, `npm run deploy` instead of remembering forge commands.

## Proposed Solution

1. Add package.json with scripts
2. npm test -> forge test
3. npm run build -> forge build
4. npm run deploy:testnet
5. npm run deploy:mainnet
6. npm run verify

## Technical Considerations

- Cross-platform compatibility
- Environment variable handling
- Error messages
- Script chaining
- Development workflow

## Priority

- [x] Low
```

---

## Issue #19

**Title:** `[DEV] Add pre-commit hooks`

**Labels:** `developer-experience`

**Description:**
```markdown
## Feature Description

Implement git pre-commit hooks to run tests, linting, and formatting before commits.

## Problem or Use Case

Prevent committing broken code, poorly formatted code, or code that fails tests.

## Proposed Solution

1. Add husky for git hooks
2. Pre-commit: run forge fmt
3. Pre-commit: run solhint
4. Pre-commit: run forge test
5. Pre-push: run full test suite

## Technical Considerations

- Hook installation
- Performance (fast checks)
- Skip option for emergencies
- CI/CD alignment
- Documentation

## Priority

- [x] Low
```

---

## Issue #20

**Title:** `[FEATURE] Improve error messages and revert reasons`

**Labels:** `enhancement`, `user-experience`

**Description:**
```markdown
## Feature Description

Enhance all error messages with clear, actionable information for users and developers.

## Problem or Use Case

Generic errors make debugging difficult. Clear messages improve developer experience.

## Proposed Solution

1. Review all custom errors
2. Add detailed error parameters
3. Include helpful context in reverts
4. Document all errors
5. Add error recovery suggestions

## Technical Considerations

- Gas cost of detailed errors
- Standardized error format
- Error codes vs messages
- Multi-language support planning
- Testing error conditions

## Priority

- [x] Low
```

---

## Quick Create Instructions

1. Go to: https://github.com/MarcusDavidG/blue-savings/issues/new
2. Copy title and description for each issue
3. Add appropriate labels
4. Click "Submit new issue"
5. Repeat for all 20 issues

OR authenticate gh CLI with: `gh configure`
