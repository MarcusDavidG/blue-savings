# Changelog

## [Unreleased]

### Planned
- ERC-20 token support
- Batch operations
- Vault templates

## [1.1.0] - 2026-01-10

### Added
- Vault metadata feature for naming and describing vaults
- 19 new view/helper functions for improved usability:
  - Statistics: getTotalVaults, getActiveVaultCount, getTotalDepositsForUser
  - Progress tracking: getVaultProgress, getRemainingToGoal, getTimeUntilUnlock
  - Status checks: isVaultUnlocked, isGoalReached, vaultExists
  - Balance queries: getVaultBalance, getTotalProtocolValue, getContractBalance
  - Metadata helpers: getVaultMetadata, getVaultOwner, isVaultOwner
  - Fee information: getCurrentFeeAmount, getMaximumFee
- Comprehensive test suite with 55+ tests
- Gas optimizations across all functions
- Security enhancements with vault existence validation
- NonexistentVault custom error for better error handling

### Changed
- Optimized storage reads with strategic caching
- Improved NatSpec documentation for all functions and events
- Enhanced code organization with section headers
- Reduced gas costs in deposit, withdraw, and calculateDepositFee functions

### Fixed
- Precompile address issue in ownership tests

### Deployed
- Base Mainnet: 0xf185cec4B72385CeaDE58507896E81F05E8b6c6a
- Base Sepolia: 0x290912Be0a52414DD8a9F3Aa7a8c35ee65A4F402
- Both contracts verified on BaseScan

## [1.0.0] - 2026-01-08

### Added
- Initial contract deployment
- Time-locked vaults with customizable unlock timestamps
- Goal-based vaults with target savings amounts
- Emergency withdrawal feature
- Protocol fee system (0.5% default, max 2%)
- Ownership transfer functionality
- Basic view functions
