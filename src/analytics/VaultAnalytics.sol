// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultAnalytics
 * @notice On-chain analytics for vault statistics
 */
contract VaultAnalytics {
    struct GlobalStats {
        uint256 totalVaults;
        uint256 totalDeposits;
        uint256 totalWithdrawals;
        uint256 totalUsers;
        uint256 totalFeesCollected;
    }

    struct UserStats {
        uint256 vaultCount;
        uint256 totalDeposited;
        uint256 totalWithdrawn;
        uint256 firstDepositTime;
        uint256 lastActivityTime;
    }

    GlobalStats public globalStats;
    mapping(address => UserStats) public userStats;
    mapping(address => bool) public isUser;

    event StatsUpdated(uint256 totalVaults, uint256 totalDeposits);

    function recordVaultCreation(address user) external {
        globalStats.totalVaults++;
        userStats[user].vaultCount++;

        if (!isUser[user]) {
            isUser[user] = true;
            globalStats.totalUsers++;
            userStats[user].firstDepositTime = block.timestamp;
        }

        userStats[user].lastActivityTime = block.timestamp;
    }

    function recordDeposit(address user, uint256 amount) external {
        globalStats.totalDeposits += amount;
        userStats[user].totalDeposited += amount;
        userStats[user].lastActivityTime = block.timestamp;

        emit StatsUpdated(globalStats.totalVaults, globalStats.totalDeposits);
    }

    function recordWithdrawal(address user, uint256 amount) external {
        globalStats.totalWithdrawals += amount;
        userStats[user].totalWithdrawn += amount;
        userStats[user].lastActivityTime = block.timestamp;
    }

    function recordFee(uint256 amount) external {
        globalStats.totalFeesCollected += amount;
    }

    function getGlobalStats() external view returns (GlobalStats memory) {
        return globalStats;
    }

    function getUserStats(address user) external view returns (UserStats memory) {
        return userStats[user];
    }

    function getTVL() external view returns (uint256) {
        return globalStats.totalDeposits - globalStats.totalWithdrawals;
    }
}
