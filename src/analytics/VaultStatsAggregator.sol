// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/ISavingsVault.sol";

/**
 * @title VaultStatsAggregator
 * @dev Aggregates and computes statistics across all vaults
 */
contract VaultStatsAggregator {
    struct GlobalStats {
        uint256 totalVaults;
        uint256 totalValueLocked;
        uint256 totalDeposits;
        uint256 totalWithdrawals;
        uint256 averageVaultSize;
        uint256 medianVaultSize;
        uint256 activeVaults;
        uint256 completedVaults;
        uint256 emergencyWithdrawals;
        uint256 lastUpdated;
    }
    
    struct VaultTypeStats {
        uint256 timeLockedVaults;
        uint256 goalBasedVaults;
        uint256 flexibleVaults;
        uint256 hybridVaults;
        uint256 timeLockedTVL;
        uint256 goalBasedTVL;
        uint256 flexibleTVL;
        uint256 hybridTVL;
    }
    
    struct PerformanceMetrics {
        uint256 averageHoldTime;
        uint256 successRate; // Percentage of vaults that reached their goals
        uint256 averageYield;
        uint256 totalFeesCollected;
        uint256 averageDepositSize;
        uint256 averageWithdrawalSize;
        uint256 vaultCompletionRate;
    }
    
    struct TimeSeriesData {
        uint256 timestamp;
        uint256 totalVaults;
        uint256 totalValueLocked;
        uint256 newVaults;
        uint256 completedVaults;
        uint256 totalVolume;
    }
    
    ISavingsVault public immutable savingsVault;
    
    GlobalStats public globalStats;
    VaultTypeStats public vaultTypeStats;
    PerformanceMetrics public performanceMetrics;
    
    mapping(uint256 => TimeSeriesData) public dailyStats;
    mapping(uint256 => uint256) public vaultSizeDistribution; // Size bucket => count
    mapping(address => uint256) public userVaultCounts;
    
    uint256 public currentDay;
    uint256 public constant SECONDS_PER_DAY = 86400;
    
    event StatsUpdated(uint256 timestamp, uint256 totalVaults, uint256 totalValueLocked);
    event DailyStatsRecorded(uint256 day, uint256 newVaults, uint256 totalTVL);
    
    constructor(address _savingsVault) {
        savingsVault = ISavingsVault(_savingsVault);
        currentDay = block.timestamp / SECONDS_PER_DAY;
    }
    
    function updateGlobalStats() external {
        uint256 vaultCounter = savingsVault.vaultCounter();
        uint256 totalTVL = 0;
        uint256 activeCount = 0;
        uint256 completedCount = 0;
        uint256 emergencyCount = 0;
        
        uint256[] memory vaultSizes = new uint256[](vaultCounter);
        uint256 validVaultCount = 0;
        
        // Reset type stats
        delete vaultTypeStats;
        
        for (uint256 i = 1; i <= vaultCounter; i++) {
            try savingsVault.getVaultDetails(i) returns (
                address owner,
                uint256 balance,
                uint256 goalAmount,
                uint256 unlockTimestamp,
                string memory,
                string memory
            ) {
                if (owner == address(0)) continue; // Skip invalid vaults
                
                totalTVL += balance;
                vaultSizes[validVaultCount] = balance;
                validVaultCount++;
                
                // Categorize vault type
                if (unlockTimestamp > 0 && goalAmount > 0) {
                    // Hybrid vault
                    vaultTypeStats.hybridVaults++;
                    vaultTypeStats.hybridTVL += balance;
                } else if (unlockTimestamp > 0) {
                    // Time-locked vault
                    vaultTypeStats.timeLockedVaults++;
                    vaultTypeStats.timeLockedTVL += balance;
                } else if (goalAmount > 0) {
                    // Goal-based vault
                    vaultTypeStats.goalBasedVaults++;
                    vaultTypeStats.goalBasedTVL += balance;
                } else {
                    // Flexible vault
                    vaultTypeStats.flexibleVaults++;
                    vaultTypeStats.flexibleTVL += balance;
                }
                
                // Check vault status
                if (balance > 0) {
                    if (goalAmount > 0 && balance >= goalAmount) {
                        completedCount++;
                    } else if (unlockTimestamp > 0 && block.timestamp >= unlockTimestamp) {
                        activeCount++;
                    } else {
                        activeCount++;
                    }
                }
                
                // Update size distribution
                uint256 sizeBucket = _getSizeBucket(balance);
                vaultSizeDistribution[sizeBucket]++;
                
            } catch {
                // Skip vaults that can't be read
                continue;
            }
        }
        
        // Calculate median vault size
        uint256 medianSize = 0;
        if (validVaultCount > 0) {
            medianSize = _calculateMedian(vaultSizes, validVaultCount);
        }
        
        // Update global stats
        globalStats = GlobalStats({
            totalVaults: validVaultCount,
            totalValueLocked: totalTVL,
            totalDeposits: 0, // Would need event tracking
            totalWithdrawals: 0, // Would need event tracking
            averageVaultSize: validVaultCount > 0 ? totalTVL / validVaultCount : 0,
            medianVaultSize: medianSize,
            activeVaults: activeCount,
            completedVaults: completedCount,
            emergencyWithdrawals: emergencyCount,
            lastUpdated: block.timestamp
        });
        
        emit StatsUpdated(block.timestamp, validVaultCount, totalTVL);
        
        // Record daily stats if new day
        uint256 today = block.timestamp / SECONDS_PER_DAY;
        if (today > currentDay) {
            _recordDailyStats(today);
            currentDay = today;
        }
    }
    
    function _recordDailyStats(uint256 day) internal {
        uint256 previousTotalVaults = 0;
        if (day > 0) {
            previousTotalVaults = dailyStats[day - 1].totalVaults;
        }
        
        uint256 newVaults = globalStats.totalVaults > previousTotalVaults 
            ? globalStats.totalVaults - previousTotalVaults 
            : 0;
        
        dailyStats[day] = TimeSeriesData({
            timestamp: day * SECONDS_PER_DAY,
            totalVaults: globalStats.totalVaults,
            totalValueLocked: globalStats.totalValueLocked,
            newVaults: newVaults,
            completedVaults: globalStats.completedVaults,
            totalVolume: 0 // Would need event tracking
        });
        
        emit DailyStatsRecorded(day, newVaults, globalStats.totalValueLocked);
    }
    
    function _getSizeBucket(uint256 amount) internal pure returns (uint256) {
        if (amount == 0) return 0;
        if (amount < 0.1 ether) return 1;
        if (amount < 0.5 ether) return 2;
        if (amount < 1 ether) return 3;
        if (amount < 5 ether) return 4;
        if (amount < 10 ether) return 5;
        if (amount < 50 ether) return 6;
        if (amount < 100 ether) return 7;
        return 8; // 100+ ETH
    }
    
    function _calculateMedian(uint256[] memory values, uint256 length) internal pure returns (uint256) {
        if (length == 0) return 0;
        
        // Simple bubble sort for small arrays
        for (uint256 i = 0; i < length - 1; i++) {
            for (uint256 j = 0; j < length - i - 1; j++) {
                if (values[j] > values[j + 1]) {
                    uint256 temp = values[j];
                    values[j] = values[j + 1];
                    values[j + 1] = temp;
                }
            }
        }
        
        if (length % 2 == 0) {
            return (values[length / 2 - 1] + values[length / 2]) / 2;
        } else {
            return values[length / 2];
        }
    }
    
    function getVaultSizeDistribution() external view returns (uint256[9] memory) {
        uint256[9] memory distribution;
        for (uint256 i = 0; i < 9; i++) {
            distribution[i] = vaultSizeDistribution[i];
        }
        return distribution;
    }
    
    function getDailyStatsRange(uint256 startDay, uint256 endDay) external view returns (TimeSeriesData[] memory) {
        require(startDay <= endDay, "Invalid date range");
        require(endDay - startDay <= 365, "Range too large"); // Max 1 year
        
        uint256 length = endDay - startDay + 1;
        TimeSeriesData[] memory stats = new TimeSeriesData[](length);
        
        for (uint256 i = 0; i < length; i++) {
            stats[i] = dailyStats[startDay + i];
        }
        
        return stats;
    }
    
    function getTopVaultsBySize(uint256 limit) external view returns (uint256[] memory vaultIds, uint256[] memory balances) {
        uint256 vaultCounter = savingsVault.vaultCounter();
        require(limit <= vaultCounter && limit <= 100, "Invalid limit");
        
        // Simple implementation - would need optimization for large datasets
        uint256[] memory allVaultIds = new uint256[](vaultCounter);
        uint256[] memory allBalances = new uint256[](vaultCounter);
        uint256 validCount = 0;
        
        for (uint256 i = 1; i <= vaultCounter; i++) {
            try savingsVault.getVaultDetails(i) returns (
                address owner,
                uint256 balance,
                uint256,
                uint256,
                string memory,
                string memory
            ) {
                if (owner != address(0) && balance > 0) {
                    allVaultIds[validCount] = i;
                    allBalances[validCount] = balance;
                    validCount++;
                }
            } catch {
                continue;
            }
        }
        
        // Sort by balance (descending)
        for (uint256 i = 0; i < validCount - 1; i++) {
            for (uint256 j = 0; j < validCount - i - 1; j++) {
                if (allBalances[j] < allBalances[j + 1]) {
                    // Swap balances
                    uint256 tempBalance = allBalances[j];
                    allBalances[j] = allBalances[j + 1];
                    allBalances[j + 1] = tempBalance;
                    
                    // Swap vault IDs
                    uint256 tempId = allVaultIds[j];
                    allVaultIds[j] = allVaultIds[j + 1];
                    allVaultIds[j + 1] = tempId;
                }
            }
        }
        
        // Return top vaults
        uint256 returnCount = validCount < limit ? validCount : limit;
        vaultIds = new uint256[](returnCount);
        balances = new uint256[](returnCount);
        
        for (uint256 i = 0; i < returnCount; i++) {
            vaultIds[i] = allVaultIds[i];
            balances[i] = allBalances[i];
        }
    }
    
    function getVaultGrowthRate(uint256 days) external view returns (int256) {
        if (days == 0) return 0;
        
        uint256 currentDayIndex = block.timestamp / SECONDS_PER_DAY;
        uint256 pastDayIndex = currentDayIndex >= days ? currentDayIndex - days : 0;
        
        uint256 currentVaults = dailyStats[currentDayIndex].totalVaults;
        uint256 pastVaults = dailyStats[pastDayIndex].totalVaults;
        
        if (pastVaults == 0) return 0;
        
        // Calculate percentage change
        int256 change = int256(currentVaults) - int256(pastVaults);
        return (change * 10000) / int256(pastVaults); // Basis points
    }
    
    function getTVLGrowthRate(uint256 days) external view returns (int256) {
        if (days == 0) return 0;
        
        uint256 currentDayIndex = block.timestamp / SECONDS_PER_DAY;
        uint256 pastDayIndex = currentDayIndex >= days ? currentDayIndex - days : 0;
        
        uint256 currentTVL = dailyStats[currentDayIndex].totalValueLocked;
        uint256 pastTVL = dailyStats[pastDayIndex].totalValueLocked;
        
        if (pastTVL == 0) return 0;
        
        // Calculate percentage change
        int256 change = int256(currentTVL) - int256(pastTVL);
        return (change * 10000) / int256(pastTVL); // Basis points
    }
    
    function getProtocolHealth() external view returns (
        uint256 healthScore,
        string memory status,
        string[] memory issues
    ) {
        healthScore = 100; // Start with perfect score
        string[] memory potentialIssues = new string[](5);
        uint256 issueCount = 0;
        
        // Check TVL growth
        int256 tvlGrowth = this.getTVLGrowthRate(30);
        if (tvlGrowth < -1000) { // -10% in 30 days
            healthScore -= 20;
            potentialIssues[issueCount] = "TVL declining";
            issueCount++;
        }
        
        // Check vault creation rate
        int256 vaultGrowth = this.getVaultGrowthRate(30);
        if (vaultGrowth < -500) { // -5% in 30 days
            healthScore -= 15;
            potentialIssues[issueCount] = "Vault creation declining";
            issueCount++;
        }
        
        // Check average vault size
        if (globalStats.averageVaultSize < 0.1 ether) {
            healthScore -= 10;
            potentialIssues[issueCount] = "Low average vault size";
            issueCount++;
        }
        
        // Check completion rate
        uint256 completionRate = globalStats.totalVaults > 0 
            ? (globalStats.completedVaults * 100) / globalStats.totalVaults 
            : 0;
        if (completionRate < 20) {
            healthScore -= 15;
            potentialIssues[issueCount] = "Low vault completion rate";
            issueCount++;
        }
        
        // Determine status
        if (healthScore >= 90) {
            status = "Excellent";
        } else if (healthScore >= 70) {
            status = "Good";
        } else if (healthScore >= 50) {
            status = "Fair";
        } else {
            status = "Poor";
        }
        
        // Return only actual issues
        issues = new string[](issueCount);
        for (uint256 i = 0; i < issueCount; i++) {
            issues[i] = potentialIssues[i];
        }
    }
}
