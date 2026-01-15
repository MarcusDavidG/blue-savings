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

    /**
     * @notice Validate batch operation parameters for operations involving tokens and amounts.
     * @dev This modifier ensures that the input arrays are not empty, have matching lengths,
     * and do not exceed the maximum batch size.
     * @param tokens Array of token addresses.
     * @param amounts Array of amounts corresponding to each token.
     */
    modifier validBatch(address[] calldata tokens, uint256[] calldata amounts) {
        if (tokens.length == 0) revert EmptyBatch();
        if (tokens.length != amounts.length) revert BatchArrayLengthMismatch();
        if (tokens.length > MAX_BATCH_SIZE) revert BatchSizeTooLarge(tokens.length);
        _;
    }

    /**
     * @notice Validate single array batch for operations involving a single array of items.
     * @dev This modifier ensures that the input array is not empty and does not exceed the maximum batch size.
     * @param items Array to validate.
     */
    modifier validSingleBatch(address[] calldata items) {
        if (items.length == 0) revert EmptyBatch();
        if (items.length > MAX_BATCH_SIZE) revert BatchSizeTooLarge(items.length);
        _;
    }

    /// @notice Batch operation result
    struct BatchResult {
        uint256 successCount;
        uint256 failCount;
        bool[] results;
    }

    /// @notice Execute batch with failure tolerance
    function _executeBatchWithTolerance(
        address[] calldata targets,
        bytes[] calldata datas,
        bool allowFailures
    ) internal returns (BatchResult memory result) {
        require(targets.length == datas.length, "Length mismatch");

        result.results = new bool[](targets.length);

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success,) = targets[i].call(datas[i]);
            result.results[i] = success;

            if (success) {
                result.successCount++;
            } else {
                result.failCount++;
                if (!allowFailures) {
                    revert("Batch operation failed");
                }
            }
        }
    }
}
