// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title RecurringDepositErrors
 * @notice Custom errors for recurring deposit operations
 */
abstract contract RecurringDepositErrors {
    /// @notice Schedule does not exist
    error ScheduleNotFound(uint256 scheduleId);

    /// @notice Caller is not schedule owner
    error NotScheduleOwner();

    /// @notice Schedule is not active
    error ScheduleNotActive(uint256 scheduleId);

    /// @notice Schedule is already paused
    error ScheduleAlreadyPaused(uint256 scheduleId);

    /// @notice Schedule is not paused
    error ScheduleNotPaused(uint256 scheduleId);

    /// @notice Not time for next execution
    error ExecutionNotDue(uint256 scheduleId, uint256 nextExecution);

    /// @notice Insufficient token allowance for schedule
    error InsufficientAllowance(address token, uint256 required, uint256 available);

    /// @notice Insufficient token balance for schedule
    error InsufficientBalance(address token, uint256 required, uint256 available);

    /// @notice Invalid schedule parameters
    error InvalidScheduleParams();

    /// @notice Maximum schedules per user exceeded
    error MaxSchedulesExceeded(uint256 max);

    /// @notice Zero executions specified
    error ZeroExecutions();

    /// @notice Invalid frequency specified
    error InvalidFrequency();
}
