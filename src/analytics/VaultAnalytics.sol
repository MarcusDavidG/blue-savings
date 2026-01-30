// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ISavingsVault.sol";

/**
 * @title VaultAnalytics
 * @dev Advanced analytics for vault performance tracking
 */
contract VaultAnalytics {
    struct VaultMetrics {
        uint256 totalDeposits;
        uint256 totalWithdrawals;
        uint256 averageHoldTime;
        uint256 successRate;
        uint256 lastUpdated;
    }

    mapping(uint256 => VaultMetrics) public vaultMetrics;
    mapping(address => uint256[]) public userVaults;
    
    ISavingsVault public immutable savingsVault;
    
    event MetricsUpdated(uint256 indexed vaultId, VaultMetrics metrics);
    
    constructor(address _savingsVault) {
        savingsVault = ISavingsVault(_savingsVault);
    }
    
    function updateVaultMetrics(uint256 vaultId) external {
        VaultMetrics storage metrics = vaultMetrics[vaultId];
        metrics.lastUpdated = block.timestamp;
        emit MetricsUpdated(vaultId, metrics);
    }
    
    function getVaultPerformance(uint256 vaultId) external view returns (VaultMetrics memory) {
        return vaultMetrics[vaultId];
    }
}
