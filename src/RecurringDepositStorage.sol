// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RecurringDepositTypes.sol";

/**
 * @title RecurringDepositStorage
 * @notice Storage layout for recurring deposits
 * @dev Mappings and state for schedule management
 */
abstract contract RecurringDepositStorage is RecurringDepositTypes {
    /// @notice Counter for schedule IDs
    uint256 public scheduleCounter;

    /// @notice Mapping of schedule ID to Schedule
    mapping(uint256 => Schedule) public schedules;

    /// @notice Mapping of user to their schedule IDs
    mapping(address => uint256[]) public userSchedules;

    /// @notice Mapping of vault to its schedule IDs
    mapping(uint256 => uint256[]) public vaultSchedules;

    /// @notice Minimum deposit amount per token (prevents dust deposits)
    mapping(address => uint256) public minDepositAmount;

    /// @notice Get schedule by ID
    function getSchedule(uint256 scheduleId) external view returns (Schedule memory) {
        return schedules[scheduleId];
    }

    /// @notice Get user's schedule IDs
    function getUserSchedules(address user) external view returns (uint256[] memory) {
        return userSchedules[user];
    }

    /// @notice Get vault's schedule IDs
    function getVaultSchedules(uint256 vaultId) external view returns (uint256[] memory) {
        return vaultSchedules[vaultId];
    }

    /// @notice Get active schedule count for user
    function getActiveScheduleCount(address user) external view returns (uint256 count) {
        uint256[] memory ids = userSchedules[user];
        for (uint256 i = 0; i < ids.length; i++) {
            if (schedules[ids[i]].status == ScheduleStatus.Active) {
                count++;
            }
        }
    }

    /// @notice Internal: Set minimum deposit for a token
    function _setMinDeposit(address token, uint256 amount) internal {
        minDepositAmount[token] = amount;
    }

    /// @notice Check if amount meets minimum threshold
    function meetsMinimum(address token, uint256 amount) public view returns (bool) {
        return amount >= minDepositAmount[token];
    }
}
