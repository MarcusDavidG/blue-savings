// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ErrorMessages
 * @notice Centralized error message strings
 */
library ErrorMessages {
    string public constant UNAUTHORIZED = "Unauthorized";
    string public constant INVALID_AMOUNT = "Invalid amount";
    string public constant VAULT_NOT_ACTIVE = "Vault not active";
    string public constant VAULT_LOCKED = "Vault locked";
    string public constant GOAL_NOT_REACHED = "Goal not reached";
    string public constant ZERO_ADDRESS = "Zero address";
    string public constant ALREADY_EXISTS = "Already exists";
    string public constant NOT_FOUND = "Not found";
    string public constant TRANSFER_FAILED = "Transfer failed";
    string public constant INSUFFICIENT_BALANCE = "Insufficient balance";
    string public constant DEADLINE_PASSED = "Deadline passed";
    string public constant NOT_OWNER = "Not owner";
    string public constant PAUSED = "Protocol paused";
}
