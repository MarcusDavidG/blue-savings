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

    /// @notice Large withdrawal threshold requiring delay
    uint256 public largeWithdrawalThreshold;

    /// @notice Delay for large withdrawals (default 24 hours)
    uint256 public withdrawalDelay = 24 hours;

    /// @notice Pending large withdrawals
    mapping(bytes32 => uint256) public pendingWithdrawals;

    event LargeWithdrawalQueued(address indexed user, uint256 amount, uint256 executeAfter);
    event WithdrawalExecuted(address indexed user, uint256 amount);

    error WithdrawalNotReady(uint256 currentTime, uint256 executeAfter);
    error WithdrawalNotFound();

    /// @notice Set threshold for large withdrawals
    function setLargeWithdrawalThreshold(uint256 threshold) external {
        largeWithdrawalThreshold = threshold;
    }

    /// @notice Check if withdrawal requires delay
    function requiresDelay(uint256 amount) public view returns (bool) {
        return largeWithdrawalThreshold > 0 && amount >= largeWithdrawalThreshold;
    }

    /// @notice Queue a large withdrawal
    function queueWithdrawal(address user, uint256 amount) external returns (bytes32 withdrawalId) {
        withdrawalId = keccak256(abi.encodePacked(user, amount, block.timestamp));
        uint256 executeAfter = block.timestamp + withdrawalDelay;
        pendingWithdrawals[withdrawalId] = executeAfter;
        emit LargeWithdrawalQueued(user, amount, executeAfter);
    }

    /// @notice Check if withdrawal can be executed
    function canExecuteWithdrawal(bytes32 withdrawalId) external view returns (bool) {
        uint256 executeAfter = pendingWithdrawals[withdrawalId];
        return executeAfter > 0 && block.timestamp >= executeAfter;
    }
}
