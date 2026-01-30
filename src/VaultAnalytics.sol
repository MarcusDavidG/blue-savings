// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IVaultMetrics.sol";

/**
 * @title VaultAnalytics
 * @dev Contract for tracking and analyzing vault performance metrics
 */
contract VaultAnalytics is IVaultMetrics {
    mapping(uint256 => VaultMetrics) private vaultMetrics;
    mapping(address => uint256[]) private userVaults;
    GlobalMetrics private globalMetrics;
    
    address public immutable savingsVault;
    address public owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender == savingsVault, "Only vault can call");
        _;
    }
    
    constructor(address _savingsVault) {
        savingsVault = _savingsVault;
        owner = msg.sender;
    }
    
    function getVaultMetrics(uint256 vaultId) external view override returns (VaultMetrics memory) {
        return vaultMetrics[vaultId];
    }
    
    function getGlobalMetrics() external view override returns (GlobalMetrics memory) {
        return globalMetrics;
    }
    
    function updateVaultMetrics(uint256 vaultId) external override onlyVault {
        VaultMetrics storage metrics = vaultMetrics[vaultId];
        metrics.lastActivityTimestamp = block.timestamp;
        emit MetricsUpdated(vaultId, metrics);
    }
    
    function recordDeposit(uint256 vaultId, uint256 amount, uint256 fee) external onlyVault {
        VaultMetrics storage metrics = vaultMetrics[vaultId];
        metrics.totalDeposits += amount;
        metrics.depositCount++;
        metrics.totalFeesPaid += fee;
        metrics.averageDepositAmount = metrics.totalDeposits / metrics.depositCount;
        metrics.lastActivityTimestamp = block.timestamp;
        
        globalMetrics.totalValueLocked += amount;
        globalMetrics.totalFeesCollected += fee;
        
        emit MetricsUpdated(vaultId, metrics);
    }
    
    function recordWithdrawal(uint256 vaultId, uint256 amount) external onlyVault {
        VaultMetrics storage metrics = vaultMetrics[vaultId];
        metrics.totalWithdrawals += amount;
        metrics.withdrawalCount++;
        metrics.lastActivityTimestamp = block.timestamp;
        
        if (metrics.creationTimestamp > 0) {
            uint256 holdingPeriod = block.timestamp - metrics.creationTimestamp;
            metrics.averageHoldingPeriod = (metrics.averageHoldingPeriod * (metrics.withdrawalCount - 1) + holdingPeriod) / metrics.withdrawalCount;
        }
        
        globalMetrics.totalValueLocked -= amount;
        
        emit MetricsUpdated(vaultId, metrics);
    }
    
    function initializeVault(uint256 vaultId, address user) external onlyVault {
        VaultMetrics storage metrics = vaultMetrics[vaultId];
        metrics.creationTimestamp = block.timestamp;
        metrics.lastActivityTimestamp = block.timestamp;
        metrics.isActive = true;
        
        userVaults[user].push(vaultId);
        globalMetrics.totalVaults++;
        globalMetrics.activeVaults++;
        
        emit MetricsUpdated(vaultId, metrics);
    }
    
    function getTopPerformingVaults(uint256 limit) external view override returns (uint256[] memory) {
        // Simple implementation - can be enhanced with more sophisticated ranking
        uint256[] memory topVaults = new uint256[](limit);
        uint256 count = 0;
        
        for (uint256 i = 1; i <= globalMetrics.totalVaults && count < limit; i++) {
            if (vaultMetrics[i].isActive && vaultMetrics[i].totalDeposits > 0) {
                topVaults[count] = i;
                count++;
            }
        }
        
        return topVaults;
    }
    
    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }
    
    function getVaultPerformanceScore(uint256 vaultId) external view returns (uint256) {
        VaultMetrics memory metrics = vaultMetrics[vaultId];
        if (!metrics.isActive || metrics.totalDeposits == 0) return 0;
        
        // Simple scoring algorithm based on consistency and size
        uint256 consistencyScore = metrics.depositCount * 10;
        uint256 sizeScore = metrics.totalDeposits / 1e15; // Normalize to reasonable range
        
        return consistencyScore + sizeScore;
    }
}
