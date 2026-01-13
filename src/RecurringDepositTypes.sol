// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title RecurringDepositTypes
 * @notice Type definitions for recurring deposit functionality
 * @dev Enums and structs for scheduled deposits
 */
abstract contract RecurringDepositTypes {
    /// @notice Frequency options for recurring deposits
    enum Frequency {
        Daily,      // Every 24 hours
        Weekly,     // Every 7 days
        BiWeekly,   // Every 14 days
        Monthly     // Every 30 days
    }

    /// @notice Status of a recurring deposit schedule
    enum ScheduleStatus {
        Active,     // Currently running
        Paused,     // Temporarily paused
        Cancelled,  // Permanently cancelled
        Completed   // All executions done
    }

    /// @notice Recurring deposit schedule configuration
    struct Schedule {
        address owner;
        uint256 vaultId;
        address token;
        uint256 amount;
        Frequency frequency;
        uint256 nextExecution;
        uint256 totalExecutions;
        uint256 executedCount;
        ScheduleStatus status;
        uint256 createdAt;
    }

    /// @notice Get interval in seconds for frequency
    /// @param freq The frequency enum value
    /// @return interval Seconds between executions
    function _getInterval(Frequency freq) internal pure returns (uint256 interval) {
        if (freq == Frequency.Daily) return 1 days;
        if (freq == Frequency.Weekly) return 7 days;
        if (freq == Frequency.BiWeekly) return 14 days;
        if (freq == Frequency.Monthly) return 30 days;
        return 1 days; // Default
    }
}
