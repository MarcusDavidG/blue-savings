// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenVaultEvents
 * @notice Event definitions for token vault operations
 * @dev Centralized events for indexing and frontend integration
 */
abstract contract TokenVaultEvents {
    /// @notice Emitted when token whitelist status changes
    event TokenWhitelistStatusChanged(address indexed token, bool whitelisted);

    /// @notice Emitted when vault is fully closed (all tokens withdrawn)
    event TokenVaultClosed(uint256 indexed vaultId, address indexed owner);

    /// @notice Emitted when vault metadata is updated
    event TokenVaultMetadataUpdated(uint256 indexed vaultId, string metadata);

    /// @notice Emitted when vault goal is updated
    event TokenVaultGoalUpdated(
        uint256 indexed vaultId,
        address newGoalToken,
        uint256 newGoalAmount
    );

    /// @notice Emitted when vault unlock time is updated
    event TokenVaultUnlockTimeUpdated(uint256 indexed vaultId, uint256 newUnlockTimestamp);

    /// @notice Emitted for batch token operations
    event BatchTokenDeposit(
        uint256 indexed vaultId,
        address indexed depositor,
        address[] tokens,
        uint256[] amounts
    );

    /// @notice Emitted for batch token withdrawals
    event BatchTokenWithdraw(
        uint256 indexed vaultId,
        address indexed owner,
        address[] tokens,
        uint256[] amounts
    );
}
