// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IVaultMetrics
 * @dev Interface for vault performance metrics and analytics
 */
interface IVaultMetrics {
    struct VaultMetrics {
        uint256 totalDeposits;
        uint256 totalWithdrawals;
        uint256 averageDepositAmount;
        uint256 depositCount;
        uint256 withdrawalCount;
        uint256 creationTimestamp;
        uint256 lastActivityTimestamp;
        uint256 totalFeesPaid;
        uint256 averageHoldingPeriod;
        bool isActive;
    }

    struct GlobalMetrics {
        uint256 totalVaults;
        uint256 totalValueLocked;
        uint256 totalFeesCollected;
        uint256 activeVaults;
        uint256 completedGoals;
        uint256 averageVaultSize;
        uint256 totalUsers;
    }

    event MetricsUpdated(uint256 indexed vaultId, VaultMetrics metrics);
    event GlobalMetricsUpdated(GlobalMetrics metrics);

    function getVaultMetrics(uint256 vaultId) external view returns (VaultMetrics memory);
    function getGlobalMetrics() external view returns (GlobalMetrics memory);
    function updateVaultMetrics(uint256 vaultId) external;
    function getTopPerformingVaults(uint256 limit) external view returns (uint256[] memory);
}
