// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title GasOptimizer
 * @dev Utilities for gas optimization and estimation
 */
library GasOptimizer {
    // Gas cost constants for common operations
    uint256 constant SSTORE_SET_GAS = 20000;
    uint256 constant SSTORE_RESET_GAS = 5000;
    uint256 constant SLOAD_GAS = 800;
    uint256 constant CALL_GAS = 700;
    uint256 constant TRANSFER_GAS = 21000;
    
    struct GasReport {
        uint256 gasUsed;
        uint256 gasPrice;
        uint256 totalCost;
        uint256 timestamp;
    }
    
    /**
     * @dev Estimate gas for vault creation
     */
    function estimateVaultCreationGas(
        bool hasGoal,
        bool hasTimelock,
        bool hasMetadata
    ) internal pure returns (uint256) {
        uint256 baseGas = 50000; // Base contract interaction
        
        if (hasGoal) baseGas += SSTORE_SET_GAS;
        if (hasTimelock) baseGas += SSTORE_SET_GAS;
        if (hasMetadata) baseGas += SSTORE_SET_GAS * 2; // Name + description
        
        return baseGas;
    }
    
    /**
     * @dev Estimate gas for deposit operation
     */
    function estimateDepositGas(
        bool isFirstDeposit,
        bool hasYieldStrategy
    ) internal pure returns (uint256) {
        uint256 baseGas = 30000;
        
        if (isFirstDeposit) baseGas += SSTORE_SET_GAS;
        if (hasYieldStrategy) baseGas += CALL_GAS * 2; // External calls
        
        return baseGas;
    }
    
    /**
     * @dev Estimate gas for withdrawal operation
     */
    function estimateWithdrawalGas(
        bool hasYieldStrategy,
        bool isEmergencyWithdrawal
    ) internal pure returns (uint256) {
        uint256 baseGas = 35000;
        
        if (hasYieldStrategy) baseGas += CALL_GAS * 3; // Yield withdrawal
        if (isEmergencyWithdrawal) baseGas += 5000; // Additional checks
        
        return baseGas + TRANSFER_GAS; // ETH transfer
    }
    
    /**
     * @dev Pack multiple boolean flags into single storage slot
     */
    function packFlags(
        bool flag1,
        bool flag2,
        bool flag3,
        bool flag4,
        bool flag5,
        bool flag6,
        bool flag7,
        bool flag8
    ) internal pure returns (uint8) {
        uint8 packed = 0;
        if (flag1) packed |= 1;
        if (flag2) packed |= 2;
        if (flag3) packed |= 4;
        if (flag4) packed |= 8;
        if (flag5) packed |= 16;
        if (flag6) packed |= 32;
        if (flag7) packed |= 64;
        if (flag8) packed |= 128;
        return packed;
    }
    
    /**
     * @dev Unpack boolean flags from storage
     */
    function unpackFlags(uint8 packed) internal pure returns (
        bool flag1,
        bool flag2,
        bool flag3,
        bool flag4,
        bool flag5,
        bool flag6,
        bool flag7,
        bool flag8
    ) {
        flag1 = (packed & 1) != 0;
        flag2 = (packed & 2) != 0;
        flag3 = (packed & 4) != 0;
        flag4 = (packed & 8) != 0;
        flag5 = (packed & 16) != 0;
        flag6 = (packed & 32) != 0;
        flag7 = (packed & 64) != 0;
        flag8 = (packed & 128) != 0;
    }
    
    /**
     * @dev Batch multiple operations to save gas
     */
    function batchOperations(
        address[] calldata targets,
        bytes[] calldata data
    ) internal returns (bool[] memory results) {
        require(targets.length == data.length, "Array length mismatch");
        
        results = new bool[](targets.length);
        
        for (uint256 i = 0; i < targets.length; i++) {
            (bool success,) = targets[i].call(data[i]);
            results[i] = success;
        }
    }
    
    /**
     * @dev Calculate optimal batch size based on gas limit
     */
    function calculateOptimalBatchSize(
        uint256 gasPerOperation,
        uint256 gasLimit
    ) internal pure returns (uint256) {
        if (gasPerOperation == 0) return 0;
        
        uint256 overhead = 21000; // Base transaction cost
        uint256 availableGas = gasLimit - overhead;
        
        return availableGas / gasPerOperation;
    }
    
    /**
     * @dev Efficient string comparison
     */
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(abi.encodePacked(a)) == keccak256(abi.encodePacked(b));
    }
    
    /**
     * @dev Gas-efficient array search
     */
    function findInArray(uint256[] memory array, uint256 value) internal pure returns (int256) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == value) {
                return int256(i);
            }
        }
        return -1;
    }
    
    /**
     * @dev Remove element from array efficiently
     */
    function removeFromArray(uint256[] storage array, uint256 index) internal {
        require(index < array.length, "Index out of bounds");
        
        // Move last element to the position to remove
        array[index] = array[array.length - 1];
        array.pop();
    }
    
    /**
     * @dev Calculate gas refund for storage cleanup
     */
    function calculateStorageRefund(uint256 slotsCleared) internal pure returns (uint256) {
        return slotsCleared * 15000; // Gas refund per cleared slot
    }
}

/**
 * @title GasTracker
 * @dev Track gas usage across operations
 */
contract GasTracker {
    using GasOptimizer for *;
    
    mapping(bytes32 => GasOptimizer.GasReport[]) public gasReports;
    mapping(address => uint256) public totalGasUsed;
    
    event GasReported(bytes32 indexed operation, uint256 gasUsed, uint256 gasPrice);
    
    modifier trackGas(bytes32 operation) {
        uint256 gasStart = gasleft();
        _;
        uint256 gasUsed = gasStart - gasleft();
        
        _recordGasUsage(operation, gasUsed);
    }
    
    function _recordGasUsage(bytes32 operation, uint256 gasUsed) internal {
        uint256 gasPrice = tx.gasprice;
        
        gasReports[operation].push(GasOptimizer.GasReport({
            gasUsed: gasUsed,
            gasPrice: gasPrice,
            totalCost: gasUsed * gasPrice,
            timestamp: block.timestamp
        }));
        
        totalGasUsed[msg.sender] += gasUsed;
        
        emit GasReported(operation, gasUsed, gasPrice);
    }
    
    function getAverageGasUsage(bytes32 operation) external view returns (uint256) {
        GasOptimizer.GasReport[] memory reports = gasReports[operation];
        if (reports.length == 0) return 0;
        
        uint256 total = 0;
        for (uint256 i = 0; i < reports.length; i++) {
            total += reports[i].gasUsed;
        }
        
        return total / reports.length;
    }
    
    function getGasReportCount(bytes32 operation) external view returns (uint256) {
        return gasReports[operation].length;
    }
    
    function getLatestGasReport(bytes32 operation) external view returns (GasOptimizer.GasReport memory) {
        GasOptimizer.GasReport[] memory reports = gasReports[operation];
        require(reports.length > 0, "No reports available");
        
        return reports[reports.length - 1];
    }
}
