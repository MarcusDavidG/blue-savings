// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IAutomation
 * @notice Interface for Chainlink-compatible automation
 * @dev Based on Chainlink Automation (Keepers) interface
 */
interface IAutomation {
    /// @notice Check if upkeep is needed
    /// @param checkData Data passed to check function
    /// @return upkeepNeeded True if upkeep should be performed
    /// @return performData Data to pass to performUpkeep
    function checkUpkeep(bytes calldata checkData)
        external
        view
        returns (bool upkeepNeeded, bytes memory performData);

    /// @notice Execute the upkeep
    /// @param performData Data from checkUpkeep
    function performUpkeep(bytes calldata performData) external;
}
