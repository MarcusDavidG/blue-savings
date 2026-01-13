// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../RecurringDepositTypes.sol";

/**
 * @title IRecurringDeposit
 * @notice Interface for RecurringDeposit contract
 */
interface IRecurringDeposit {
    function createSchedule(
        uint256 vaultId,
        address token,
        uint256 amount,
        RecurringDepositTypes.Frequency frequency,
        uint256 totalExecutions,
        uint256 startTime
    ) external returns (uint256 scheduleId);

    function pauseSchedule(uint256 scheduleId) external;

    function resumeSchedule(uint256 scheduleId) external;

    function cancelSchedule(uint256 scheduleId) external;

    function executeSchedule(uint256 scheduleId) external;

    function getSchedule(uint256 scheduleId) 
        external 
        view 
        returns (RecurringDepositTypes.Schedule memory);

    function getUserSchedules(address user) external view returns (uint256[] memory);

    function getVaultSchedules(uint256 vaultId) external view returns (uint256[] memory);

    function getActiveScheduleCount(address user) external view returns (uint256);
}
