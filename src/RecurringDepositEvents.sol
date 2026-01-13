// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RecurringDepositTypes.sol";

/**
 * @title RecurringDepositEvents
 * @notice Events for recurring deposit operations
 */
abstract contract RecurringDepositEvents is RecurringDepositTypes {
    /// @notice Emitted when a new schedule is created
    event ScheduleCreated(
        uint256 indexed scheduleId,
        address indexed owner,
        uint256 indexed vaultId,
        address token,
        uint256 amount,
        Frequency frequency
    );

    /// @notice Emitted when a scheduled deposit executes
    event ScheduledDepositExecuted(
        uint256 indexed scheduleId,
        uint256 indexed vaultId,
        uint256 amount,
        uint256 executionNumber
    );

    /// @notice Emitted when schedule is paused
    event SchedulePaused(uint256 indexed scheduleId);

    /// @notice Emitted when schedule is resumed
    event ScheduleResumed(uint256 indexed scheduleId);

    /// @notice Emitted when schedule is cancelled
    event ScheduleCancelled(uint256 indexed scheduleId);

    /// @notice Emitted when schedule completes all executions
    event ScheduleCompleted(uint256 indexed scheduleId, uint256 totalExecuted);

    /// @notice Emitted when schedule amount is updated
    event ScheduleAmountUpdated(uint256 indexed scheduleId, uint256 oldAmount, uint256 newAmount);

    /// @notice Emitted when schedule frequency is updated
    event ScheduleFrequencyUpdated(uint256 indexed scheduleId, Frequency oldFreq, Frequency newFreq);
}
