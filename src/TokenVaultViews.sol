// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenVaultViews
 * @notice View functions for token vault statistics
 * @dev Provides read-only utility functions for frontend integration
 */
abstract contract TokenVaultViews {
    /// @notice Check if a token vault can be withdrawn
    /// @param vaultId The vault ID
    /// @param goalToken The goal token address
    /// @param goalAmount The goal amount
    /// @param unlockTimestamp The unlock timestamp
    /// @param tokenBalance Current balance of goal token
    /// @return canWithdraw Whether withdrawal is allowed
    function _canWithdrawTokenVault(
        uint256 vaultId,
        address goalToken,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        uint256 tokenBalance
    ) internal view returns (bool canWithdraw) {
        // Check time lock
        if (unlockTimestamp != 0 && block.timestamp < unlockTimestamp) {
            return false;
        }

        // Check goal
        if (goalToken != address(0) && goalAmount != 0) {
            if (tokenBalance < goalAmount) {
                return false;
            }
        }

        return true;
    }

    /// @notice Calculate time remaining until unlock
    /// @param unlockTimestamp The unlock timestamp
    /// @return Time in seconds until unlock (0 if unlocked)
    function _getTimeUntilUnlock(uint256 unlockTimestamp) internal view returns (uint256) {
        if (unlockTimestamp == 0 || block.timestamp >= unlockTimestamp) {
            return 0;
        }
        unchecked {
            return unlockTimestamp - block.timestamp;
        }
    }

    /// @notice Calculate progress towards goal in basis points
    /// @param currentBalance Current balance
    /// @param goalAmount Goal amount
    /// @return progress Progress in bps (10000 = 100%)
    function _getGoalProgress(
        uint256 currentBalance,
        uint256 goalAmount
    ) internal pure returns (uint256 progress) {
        if (goalAmount == 0) {
            return 10000; // No goal = 100%
        }
        if (currentBalance >= goalAmount) {
            return 10000;
        }
        return (currentBalance * 10000) / goalAmount;
    }

    /// @notice Calculate remaining amount to reach goal
    /// @param currentBalance Current balance
    /// @param goalAmount Goal amount
    /// @return remaining Amount remaining (0 if goal reached)
    function _getRemainingToGoal(
        uint256 currentBalance,
        uint256 goalAmount
    ) internal pure returns (uint256 remaining) {
        if (goalAmount == 0 || currentBalance >= goalAmount) {
            return 0;
        }
        unchecked {
            return goalAmount - currentBalance;
        }
    }
}
