// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Limits
 * @notice Protocol limits and boundaries
 */
library Limits {
    uint256 public constant MAX_VAULTS_PER_USER = 100;
    uint256 public constant MAX_TOKENS_PER_VAULT = 10;
    uint256 public constant MAX_SIGNERS_MULTISIG = 10;
    uint256 public constant MIN_SIGNERS_MULTISIG = 2;
    uint256 public constant MAX_LOCK_DURATION = 365 days * 10; // 10 years
    uint256 public constant MIN_DEPOSIT = 0.001 ether;
    uint256 public constant MAX_BATCH_SIZE = 50;
    uint256 public constant MAX_SCHEDULES_PER_USER = 10;
}
