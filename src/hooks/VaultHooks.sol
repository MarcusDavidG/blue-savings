// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultHooks
 * @notice Hook system for vault operations
 * @dev Allows custom logic before/after deposit/withdraw
 */
abstract contract VaultHooks {
    /// @notice Hook called before deposit
    function _beforeDeposit(address user, uint256 vaultId, uint256 amount) internal virtual {}

    /// @notice Hook called after deposit
    function _afterDeposit(address user, uint256 vaultId, uint256 amount) internal virtual {}

    /// @notice Hook called before withdraw
    function _beforeWithdraw(address user, uint256 vaultId, uint256 amount) internal virtual {}

    /// @notice Hook called after withdraw
    function _afterWithdraw(address user, uint256 vaultId, uint256 amount) internal virtual {}

    /// @notice Hook called on vault creation
    function _onVaultCreated(address owner, uint256 vaultId) internal virtual {}

    /// @notice Hook called on vault close
    function _onVaultClosed(address owner, uint256 vaultId) internal virtual {}
}
