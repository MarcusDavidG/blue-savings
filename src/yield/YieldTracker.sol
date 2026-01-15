// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title YieldTracker
 * @notice Tracks yield performance metrics over time
 * @dev Records historical yields for reporting and analytics
 */
contract YieldTracker {
    struct YieldRecord {
        uint256 timestamp;
        uint256 deposited;
        uint256 withdrawn;
        uint256 yieldEarned;
        uint256 apy;
    }

    /// @notice Historical yield records per token
    mapping(address => YieldRecord[]) public yieldHistory;

    /// @notice Total yield earned per token
    mapping(address => uint256) public totalYieldEarned;

    /// @notice Total deposited per token (for calculating returns)
    mapping(address => uint256) public totalDeposited;

    /// @notice First deposit timestamp per token
    mapping(address => uint256) public firstDepositTime;

    event YieldRecorded(address indexed token, uint256 amount, uint256 apy);

    /// @notice Record yield earned
    function _recordYield(address token, uint256 amount, uint256 apy) internal {
        yieldHistory[token].push(YieldRecord({
            timestamp: block.timestamp,
            deposited: 0,
            withdrawn: 0,
            yieldEarned: amount,
            apy: apy
        }));

        totalYieldEarned[token] += amount;
        emit YieldRecorded(token, amount, apy);
    }

    /// @notice Record deposit
    function _recordDeposit(address token, uint256 amount) internal {
        if (firstDepositTime[token] == 0) {
            firstDepositTime[token] = block.timestamp;
        }
        totalDeposited[token] += amount;

        yieldHistory[token].push(YieldRecord({
            timestamp: block.timestamp,
            deposited: amount,
            withdrawn: 0,
            yieldEarned: 0,
            apy: 0
        }));
    }

    /// @notice Get historical average APY
    function getAverageAPY(address token) external view returns (uint256) {
        YieldRecord[] memory history = yieldHistory[token];
        if (history.length == 0) return 0;

        uint256 totalApy;
        uint256 count;
        for (uint256 i = 0; i < history.length; i++) {
            if (history[i].apy > 0) {
                totalApy += history[i].apy;
                count++;
            }
        }

        return count > 0 ? totalApy / count : 0;
    }

    /// @notice Get total return percentage (basis points)
    function getTotalReturnBps(address token) external view returns (uint256) {
        if (totalDeposited[token] == 0) return 0;
        return (totalYieldEarned[token] * 10000) / totalDeposited[token];
    }

    /// @notice Get yield history length
    function getHistoryLength(address token) external view returns (uint256) {
        return yieldHistory[token].length;
    }
}
