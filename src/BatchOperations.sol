// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BatchOperations
 * @notice Batch operation utilities for vault operations
 * @dev Abstract contract for multi-token batch processing
 */
abstract contract BatchOperations {
    /// @notice Maximum tokens per batch operation
    uint256 public constant MAX_BATCH_SIZE = 20;

    /// @notice Thrown when batch arrays have different lengths
    error BatchArrayLengthMismatch();

    /// @notice Thrown when batch is empty
    error EmptyBatch();

    /// @notice Thrown when batch exceeds maximum size
    error BatchSizeTooLarge(uint256 size);

    /// @notice Validate batch operation parameters
    /// @param tokens Array of token addresses
    /// @param amounts Array of amounts
    modifier validBatch(address[] calldata tokens, uint256[] calldata amounts) {
        if (tokens.length == 0) revert EmptyBatch();
        if (tokens.length != amounts.length) revert BatchArrayLengthMismatch();
        if (tokens.length > MAX_BATCH_SIZE) revert BatchSizeTooLarge(tokens.length);
        _;
    }

    /// @notice Validate single array batch
    /// @param items Array to validate
    modifier validSingleBatch(address[] calldata items) {
        if (items.length == 0) revert EmptyBatch();
        if (items.length > MAX_BATCH_SIZE) revert BatchSizeTooLarge(items.length);
        _;
    }
}
