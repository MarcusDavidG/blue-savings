// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title DeadlineChecker
 * @notice Deadline validation for time-sensitive operations
 */
abstract contract DeadlineChecker {
    error DeadlineExpired();

    modifier checkDeadline(uint256 deadline) {
        if (block.timestamp > deadline) revert DeadlineExpired();
        _;
    }
}
