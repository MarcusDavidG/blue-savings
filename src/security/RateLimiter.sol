// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title RateLimiter
 * @notice Rate limiting for withdrawals and large operations
 */
contract RateLimiter {
    struct RateLimit {
        uint256 maxAmount;
        uint256 windowDuration;
        uint256 currentAmount;
        uint256 windowStart;
    }

    mapping(address => RateLimit) public userLimits;
    RateLimit public globalLimit;

    event RateLimitExceeded(address indexed user, uint256 requested, uint256 available);
    event WindowReset(address indexed user, uint256 timestamp);

    error RateLimitExceededError(uint256 requested, uint256 available);

    constructor(uint256 globalMax, uint256 windowDuration) {
        globalLimit = RateLimit({
            maxAmount: globalMax,
            windowDuration: windowDuration,
            currentAmount: 0,
            windowStart: block.timestamp
        });
    }

    function checkAndUpdateLimit(address user, uint256 amount) external returns (bool) {
        _resetWindowIfNeeded(user);
        _resetGlobalWindowIfNeeded();

        uint256 userAvailable = _getUserAvailable(user);
        uint256 globalAvailable = globalLimit.maxAmount - globalLimit.currentAmount;

        if (amount > userAvailable || amount > globalAvailable) {
            emit RateLimitExceeded(user, amount, userAvailable < globalAvailable ? userAvailable : globalAvailable);
            revert RateLimitExceededError(amount, userAvailable < globalAvailable ? userAvailable : globalAvailable);
        }

        userLimits[user].currentAmount += amount;
        globalLimit.currentAmount += amount;

        return true;
    }

    function setUserLimit(address user, uint256 maxAmount, uint256 windowDuration) external {
        userLimits[user].maxAmount = maxAmount;
        userLimits[user].windowDuration = windowDuration;
    }

    function _resetWindowIfNeeded(address user) internal {
        if (block.timestamp >= userLimits[user].windowStart + userLimits[user].windowDuration) {
            userLimits[user].currentAmount = 0;
            userLimits[user].windowStart = block.timestamp;
            emit WindowReset(user, block.timestamp);
        }
    }

    function _resetGlobalWindowIfNeeded() internal {
        if (block.timestamp >= globalLimit.windowStart + globalLimit.windowDuration) {
            globalLimit.currentAmount = 0;
            globalLimit.windowStart = block.timestamp;
        }
    }

    function _getUserAvailable(address user) internal view returns (uint256) {
        if (userLimits[user].maxAmount == 0) return type(uint256).max;
        return userLimits[user].maxAmount - userLimits[user].currentAmount;
    }

    function getAvailableLimit(address user) external view returns (uint256 userAvail, uint256 globalAvail) {
        userAvail = _getUserAvailable(user);
        globalAvail = globalLimit.maxAmount - globalLimit.currentAmount;
    }
}
