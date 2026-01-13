// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MultiSigTypes
 * @notice Type definitions for multi-sig vault functionality
 */
abstract contract MultiSigTypes {
    /// @notice Transaction status
    enum TxStatus {
        Pending,
        Executed,
        Cancelled
    }

    /// @notice Multi-sig vault configuration
    struct MultiSigConfig {
        address[] signers;
        uint256 threshold;
        uint256 txCount;
        bool isActive;
    }

    /// @notice Proposed transaction
    struct Transaction {
        uint256 vaultId;
        address to;
        uint256 value;
        bytes data;
        uint256 approvalCount;
        TxStatus status;
        uint256 createdAt;
        uint256 executedAt;
    }
}
