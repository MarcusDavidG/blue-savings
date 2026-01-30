// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./libraries/GasOptimizer.sol";

/**
 * @title BatchOperations
 * @dev Efficient batch operations for multiple vault interactions
 */
contract BatchOperations {
    using GasOptimizer for uint256[];
    
    address public immutable savingsVault;
    address public owner;
    
    struct BatchResult {
        uint256 successCount;
        uint256 failureCount;
        uint256 totalGasUsed;
        bytes[] results;
    }
    
    event BatchDepositCompleted(uint256 successCount, uint256 failureCount);
    event BatchWithdrawCompleted(uint256 successCount, uint256 failureCount);
    event BatchCreateCompleted(uint256 successCount, uint256 failureCount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    constructor(address _savingsVault) {
        savingsVault = _savingsVault;
        owner = msg.sender;
    }
    
    /**
     * @dev Batch deposit to multiple vaults
     */
    function batchDeposit(
        uint256[] calldata vaultIds,
        uint256[] calldata amounts
    ) external payable returns (BatchResult memory result) {
        require(vaultIds.length == amounts.length, "Array length mismatch");
        GasOptimizer.validateBatch(vaultIds.length);
        GasOptimizer.checkGasRequirement(vaultIds.length);
        
        uint256 totalAmount = amounts.sumArray();
        require(msg.value >= totalAmount, "Insufficient ETH sent");
        
        result.results = new bytes[](vaultIds.length);
        uint256 gasStart = gasleft();
        
        for (uint256 i = 0; i < vaultIds.length;) {
            try this.singleDeposit{value: amounts[i]}(vaultIds[i]) {
                result.successCount++;
                result.results[i] = abi.encode(true, "Success");
            } catch Error(string memory reason) {
                result.failureCount++;
                result.results[i] = abi.encode(false, reason);
            } catch {
                result.failureCount++;
                result.results[i] = abi.encode(false, "Unknown error");
            }
            
            unchecked { ++i; }
        }
        
        result.totalGasUsed = gasStart - gasleft();
        
        // Refund excess ETH
        uint256 refund = msg.value - totalAmount;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        
        emit BatchDepositCompleted(result.successCount, result.failureCount);
    }
    
    /**
     * @dev Batch withdraw from multiple vaults
     */
    function batchWithdraw(
        uint256[] calldata vaultIds
    ) external returns (BatchResult memory result) {
        GasOptimizer.validateBatch(vaultIds.length);
        GasOptimizer.checkGasRequirement(vaultIds.length);
        
        result.results = new bytes[](vaultIds.length);
        uint256 gasStart = gasleft();
        
        for (uint256 i = 0; i < vaultIds.length;) {
            try this.singleWithdraw(vaultIds[i]) {
                result.successCount++;
                result.results[i] = abi.encode(true, "Success");
            } catch Error(string memory reason) {
                result.failureCount++;
                result.results[i] = abi.encode(false, reason);
            } catch {
                result.failureCount++;
                result.results[i] = abi.encode(false, "Unknown error");
            }
            
            unchecked { ++i; }
        }
        
        result.totalGasUsed = gasStart - gasleft();
        emit BatchWithdrawCompleted(result.successCount, result.failureCount);
    }
    
    /**
     * @dev Batch create multiple vaults
     */
    function batchCreateVaults(
        uint256[] calldata goalAmounts,
        uint256[] calldata unlockTimestamps,
        string[] calldata names,
        string[] calldata descriptions
    ) external returns (BatchResult memory result) {
        require(
            goalAmounts.length == unlockTimestamps.length &&
            unlockTimestamps.length == names.length &&
            names.length == descriptions.length,
            "Array length mismatch"
        );
        
        GasOptimizer.validateBatch(goalAmounts.length);
        GasOptimizer.checkGasRequirement(goalAmounts.length);
        
        result.results = new bytes[](goalAmounts.length);
        uint256 gasStart = gasleft();
        
        for (uint256 i = 0; i < goalAmounts.length;) {
            try this.singleCreateVault(
                goalAmounts[i],
                unlockTimestamps[i],
                names[i],
                descriptions[i]
            ) returns (uint256 vaultId) {
                result.successCount++;
                result.results[i] = abi.encode(true, vaultId);
            } catch Error(string memory reason) {
                result.failureCount++;
                result.results[i] = abi.encode(false, reason);
            } catch {
                result.failureCount++;
                result.results[i] = abi.encode(false, "Unknown error");
            }
            
            unchecked { ++i; }
        }
        
        result.totalGasUsed = gasStart - gasleft();
        emit BatchCreateCompleted(result.successCount, result.failureCount);
    }
    
    /**
     * @dev Single deposit operation (internal)
     */
    function singleDeposit(uint256 vaultId) external payable {
        require(msg.sender == address(this), "Internal function");
        
        (bool success,) = savingsVault.call{value: msg.value}(
            abi.encodeWithSignature("deposit(uint256)", vaultId)
        );
        require(success, "Deposit failed");
    }
    
    /**
     * @dev Single withdraw operation (internal)
     */
    function singleWithdraw(uint256 vaultId) external {
        require(msg.sender == address(this), "Internal function");
        
        (bool success,) = savingsVault.call(
            abi.encodeWithSignature("withdraw(uint256)", vaultId)
        );
        require(success, "Withdraw failed");
    }
    
    /**
     * @dev Single vault creation (internal)
     */
    function singleCreateVault(
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string memory name,
        string memory description
    ) external returns (uint256) {
        require(msg.sender == address(this), "Internal function");
        
        (bool success, bytes memory data) = savingsVault.call(
            abi.encodeWithSignature(
                "createVault(uint256,uint256,string,string)",
                goalAmount,
                unlockTimestamp,
                name,
                description
            )
        );
        require(success, "Create vault failed");
        
        return abi.decode(data, (uint256));
    }
    
    /**
     * @dev Get optimal batch size for current gas conditions
     */
    function getOptimalBatchSize() external view returns (uint256) {
        return GasOptimizer.calculateOptimalBatchSize(gasleft());
    }
    
    /**
     * @dev Estimate gas for batch operations
     */
    function estimateBatchGas(uint256 operationCount) external pure returns (uint256) {
        return operationCount * 100000; // Rough estimate per operation
    }
    
    /**
     * @dev Emergency function to recover stuck ETH
     */
    function emergencyWithdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
    
    /**
     * @dev Update savings vault address (if needed)
     */
    function updateSavingsVault(address newVault) external onlyOwner {
        require(newVault != address(0), "Invalid address");
        // Note: This would require making savingsVault mutable
        // For now, it's immutable for security
    }
    
    receive() external payable {
        // Allow contract to receive ETH
    }
}
