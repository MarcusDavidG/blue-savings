// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ValidationLib
 * @notice Common validation logic for vault operations
 */
library ValidationLib {
    error ZeroAddress();
    error ZeroAmount();
    error InvalidTimestamp();
    error AmountTooLarge(uint256 amount, uint256 max);
    error AmountTooSmall(uint256 amount, uint256 min);
    error DeadlineExpired(uint256 deadline, uint256 current);

    function requireNonZeroAddress(address addr) internal pure {
        if (addr == address(0)) revert ZeroAddress();
    }

    function requireNonZeroAmount(uint256 amount) internal pure {
        if (amount == 0) revert ZeroAmount();
    }

    function requireValidDeadline(uint256 deadline) internal view {
        if (deadline < block.timestamp) revert DeadlineExpired(deadline, block.timestamp);
    }

    function requireFutureTimestamp(uint256 timestamp) internal view {
        if (timestamp != 0 && timestamp <= block.timestamp) revert InvalidTimestamp();
    }

    function requireAmountInRange(uint256 amount, uint256 min, uint256 max) internal pure {
        if (amount < min) revert AmountTooSmall(amount, min);
        if (amount > max) revert AmountTooLarge(amount, max);
    }
}
