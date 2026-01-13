// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenVaultErrors
 * @notice Custom error definitions for token vault operations
 * @dev Centralized errors for gas-efficient reverts
 */
abstract contract TokenVaultErrors {
    /// @notice Thrown when array lengths don't match
    error ArrayLengthMismatch();

    /// @notice Thrown when batch operation is empty
    error EmptyBatch();

    /// @notice Thrown when batch size exceeds maximum
    error BatchTooLarge(uint256 size, uint256 max);

    /// @notice Thrown when token transfer fails
    error TokenTransferFailed(address token);

    /// @notice Thrown when permit signature is invalid
    error InvalidPermitSignature();

    /// @notice Thrown when permit deadline has passed
    error PermitExpired();

    /// @notice Thrown when vault has insufficient token balance
    error InsufficientTokenBalance(address token, uint256 requested, uint256 available);

    /// @notice Thrown when token is already in vault
    error TokenAlreadyInVault(address token);

    /// @notice Thrown when maximum tokens per vault exceeded
    error MaxTokensExceeded(uint256 current, uint256 max);

    /// @notice Thrown when trying to operate on closed vault
    error VaultClosed(uint256 vaultId);

    /// @notice Thrown when goal token mismatch
    error GoalTokenMismatch(address expected, address provided);

    /// @notice Thrown when trying to set invalid unlock time
    error InvalidUnlockTime(uint256 provided, uint256 minimum);
}
