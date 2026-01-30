// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title GasOptimizer
 * @dev Gas optimization utilities and batch operations
 */
library GasOptimizer {
    struct BatchDeposit {
        uint256 vaultId;
        uint256 amount;
    }
    
    struct BatchWithdraw {
        uint256 vaultId;
        uint256 amount;
    }
    
    error InsufficientGas();
    error BatchSizeExceeded();
    error InvalidBatchOperation();
    
    uint256 private constant MAX_BATCH_SIZE = 50;
    uint256 private constant MIN_GAS_PER_OPERATION = 50000;
    
    /**
     * @dev Validates batch operation parameters
     */
    function validateBatch(uint256 batchSize) internal pure {
        if (batchSize == 0) revert InvalidBatchOperation();
        if (batchSize > MAX_BATCH_SIZE) revert BatchSizeExceeded();
    }
    
    /**
     * @dev Checks if there's sufficient gas for batch operations
     */
    function checkGasRequirement(uint256 operationCount) internal view {
        uint256 requiredGas = operationCount * MIN_GAS_PER_OPERATION;
        if (gasleft() < requiredGas) revert InsufficientGas();
    }
    
    /**
     * @dev Optimized storage packing for vault data
     */
    function packVaultData(
        uint128 goalAmount,
        uint64 unlockTimestamp,
        uint32 depositCount,
        uint32 flags
    ) internal pure returns (uint256 packed) {
        packed = uint256(goalAmount);
        packed |= uint256(unlockTimestamp) << 128;
        packed |= uint256(depositCount) << 192;
        packed |= uint256(flags) << 224;
    }
    
    /**
     * @dev Unpacks vault data from storage
     */
    function unpackVaultData(uint256 packed) internal pure returns (
        uint128 goalAmount,
        uint64 unlockTimestamp,
        uint32 depositCount,
        uint32 flags
    ) {
        goalAmount = uint128(packed);
        unlockTimestamp = uint64(packed >> 128);
        depositCount = uint32(packed >> 192);
        flags = uint32(packed >> 224);
    }
    
    /**
     * @dev Calculates optimal batch size based on available gas
     */
    function calculateOptimalBatchSize(uint256 availableGas) internal pure returns (uint256) {
        uint256 maxOperations = availableGas / MIN_GAS_PER_OPERATION;
        return maxOperations > MAX_BATCH_SIZE ? MAX_BATCH_SIZE : maxOperations;
    }
    
    /**
     * @dev Efficient array sum calculation
     */
    function sumArray(uint256[] memory amounts) internal pure returns (uint256 total) {
        uint256 length = amounts.length;
        for (uint256 i = 0; i < length;) {
            total += amounts[i];
            unchecked { ++i; }
        }
    }
    
    /**
     * @dev Gas-efficient event emission for batch operations
     */
    function emitBatchEvent(
        bytes32 eventSignature,
        uint256[] memory vaultIds,
        uint256[] memory amounts
    ) internal {
        uint256 length = vaultIds.length;
        for (uint256 i = 0; i < length;) {
            assembly {
                let vaultId := mload(add(add(vaultIds, 0x20), mul(i, 0x20)))
                let amount := mload(add(add(amounts, 0x20), mul(i, 0x20)))
                
                log3(
                    0,
                    0,
                    eventSignature,
                    vaultId,
                    amount
                )
            }
            unchecked { ++i; }
        }
    }
    
    /**
     * @dev Memory-efficient array copying
     */
    function copyArray(uint256[] memory source) internal pure returns (uint256[] memory) {
        uint256 length = source.length;
        uint256[] memory destination = new uint256[](length);
        
        assembly {
            let sourcePtr := add(source, 0x20)
            let destPtr := add(destination, 0x20)
            let size := mul(length, 0x20)
            
            // Use efficient memory copy
            for { let i := 0 } lt(i, size) { i := add(i, 0x20) } {
                mstore(add(destPtr, i), mload(add(sourcePtr, i)))
            }
        }
        
        return destination;
    }
    
    /**
     * @dev Optimized percentage calculation with rounding
     */
    function calculatePercentage(
        uint256 amount,
        uint256 percentage,
        uint256 basis
    ) internal pure returns (uint256) {
        return (amount * percentage + basis / 2) / basis;
    }
    
    /**
     * @dev Safe math operations with gas optimization
     */
    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a, "Addition overflow");
    }
    
    function safeSub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a, "Subtraction underflow");
        c = a - b;
    }
    
    function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) return 0;
        c = a * b;
        require(c / a == b, "Multiplication overflow");
    }
}
