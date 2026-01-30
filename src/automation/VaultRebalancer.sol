// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/ISavingsVault.sol";

/**
 * @title VaultRebalancer
 * @dev Automated rebalancing system for vault portfolios
 */
contract VaultRebalancer is Ownable, ReentrancyGuard {
    struct RebalanceStrategy {
        uint256 id;
        string name;
        address owner;
        uint256[] vaultIds;
        uint256[] targetAllocations; // Basis points (10000 = 100%)
        uint256 rebalanceThreshold; // Basis points deviation to trigger rebalance
        uint256 minRebalanceInterval; // Minimum time between rebalances
        uint256 lastRebalance;
        bool isActive;
        RebalanceType rebalanceType;
    }
    
    struct RebalanceExecution {
        uint256 strategyId;
        uint256 timestamp;
        uint256[] fromVaults;
        uint256[] toVaults;
        uint256[] amounts;
        uint256 gasUsed;
        bool success;
        string reason;
    }
    
    enum RebalanceType { EQUAL_WEIGHT, TARGET_ALLOCATION, RISK_PARITY, MOMENTUM }
    
    mapping(uint256 => RebalanceStrategy) public strategies;
    mapping(uint256 => RebalanceExecution[]) public executionHistory;
    mapping(address => uint256[]) public userStrategies;
    mapping(uint256 => mapping(uint256 => uint256)) public vaultAllocations;
    
    uint256 public strategyCounter;
    uint256 public rebalanceFee = 0.001 ether;
    uint256 public constant MAX_VAULTS_PER_STRATEGY = 20;
    uint256 public constant MIN_REBALANCE_INTERVAL = 1 hours;
    uint256 public constant MAX_REBALANCE_THRESHOLD = 5000; // 50%
    
    ISavingsVault public immutable savingsVault;
    
    event StrategyCreated(uint256 indexed strategyId, address indexed owner, string name);
    event RebalanceExecuted(uint256 indexed strategyId, uint256 totalAmount, uint256 gasUsed);
    event RebalanceFailed(uint256 indexed strategyId, string reason);
    event StrategyUpdated(uint256 indexed strategyId, uint256[] newAllocations);
    event StrategyDeactivated(uint256 indexed strategyId);
    
    modifier validStrategy(uint256 strategyId) {
        require(strategyId > 0 && strategyId <= strategyCounter, "Invalid strategy ID");
        _;
    }
    
    modifier onlyStrategyOwner(uint256 strategyId) {
        require(strategies[strategyId].owner == msg.sender, "Not strategy owner");
        _;
    }
    
    constructor(address _savingsVault) Ownable(msg.sender) {
        savingsVault = ISavingsVault(_savingsVault);
    }
    
    function createRebalanceStrategy(
        string calldata name,
        uint256[] calldata vaultIds,
        uint256[] calldata targetAllocations,
        uint256 rebalanceThreshold,
        uint256 minRebalanceInterval,
        RebalanceType rebalanceType
    ) external payable returns (uint256) {
        require(msg.value >= rebalanceFee, "Insufficient fee");
        require(vaultIds.length > 1, "Need at least 2 vaults");
        require(vaultIds.length <= MAX_VAULTS_PER_STRATEGY, "Too many vaults");
        require(vaultIds.length == targetAllocations.length, "Array length mismatch");
        require(rebalanceThreshold <= MAX_REBALANCE_THRESHOLD, "Threshold too high");
        require(minRebalanceInterval >= MIN_REBALANCE_INTERVAL, "Interval too short");
        
        // Validate allocations sum to 100%
        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < targetAllocations.length; i++) {
            totalAllocation += targetAllocations[i];
        }
        require(totalAllocation == 10000, "Allocations must sum to 100%");
        
        // Verify vault ownership
        for (uint256 i = 0; i < vaultIds.length; i++) {
            (address vaultOwner,,,,,) = savingsVault.getVaultDetails(vaultIds[i]);
            require(vaultOwner == msg.sender, "Not vault owner");
        }
        
        uint256 strategyId = ++strategyCounter;
        
        strategies[strategyId] = RebalanceStrategy({
            id: strategyId,
            name: name,
            owner: msg.sender,
            vaultIds: vaultIds,
            targetAllocations: targetAllocations,
            rebalanceThreshold: rebalanceThreshold,
            minRebalanceInterval: minRebalanceInterval,
            lastRebalance: 0,
            isActive: true,
            rebalanceType: rebalanceType
        });
        
        userStrategies[msg.sender].push(strategyId);
        
        emit StrategyCreated(strategyId, msg.sender, name);
        
        // Refund excess fee
        if (msg.value > rebalanceFee) {
            payable(msg.sender).transfer(msg.value - rebalanceFee);
        }
        
        return strategyId;
    }
    
    function executeRebalance(uint256 strategyId) external validStrategy(strategyId) nonReentrant {
        RebalanceStrategy storage strategy = strategies[strategyId];
        require(strategy.isActive, "Strategy not active");
        require(
            block.timestamp >= strategy.lastRebalance + strategy.minRebalanceInterval,
            "Rebalance interval not met"
        );
        
        uint256 gasStart = gasleft();
        
        try this._performRebalance(strategyId) {
            strategy.lastRebalance = block.timestamp;
            
            uint256 gasUsed = gasStart - gasleft();
            
            // Record successful execution
            RebalanceExecution memory execution = RebalanceExecution({
                strategyId: strategyId,
                timestamp: block.timestamp,
                fromVaults: new uint256[](0),
                toVaults: new uint256[](0),
                amounts: new uint256[](0),
                gasUsed: gasUsed,
                success: true,
                reason: "Rebalance completed successfully"
            });
            
            executionHistory[strategyId].push(execution);
            
            emit RebalanceExecuted(strategyId, _getTotalStrategyValue(strategyId), gasUsed);
            
        } catch Error(string memory reason) {
            // Record failed execution
            RebalanceExecution memory execution = RebalanceExecution({
                strategyId: strategyId,
                timestamp: block.timestamp,
                fromVaults: new uint256[](0),
                toVaults: new uint256[](0),
                amounts: new uint256[](0),
                gasUsed: gasStart - gasleft(),
                success: false,
                reason: reason
            });
            
            executionHistory[strategyId].push(execution);
            
            emit RebalanceFailed(strategyId, reason);
        }
    }
    
    function _performRebalance(uint256 strategyId) external {
        require(msg.sender == address(this), "Internal function");
        
        RebalanceStrategy memory strategy = strategies[strategyId];
        uint256 totalValue = _getTotalStrategyValue(strategyId);
        
        if (totalValue == 0) return;
        
        // Calculate current allocations
        uint256[] memory currentAllocations = new uint256[](strategy.vaultIds.length);
        uint256[] memory currentValues = new uint256[](strategy.vaultIds.length);
        
        for (uint256 i = 0; i < strategy.vaultIds.length; i++) {
            (, uint256 balance,,,) = savingsVault.getVaultDetails(strategy.vaultIds[i]);
            currentValues[i] = balance;
            currentAllocations[i] = (balance * 10000) / totalValue;
        }
        
        // Check if rebalancing is needed
        bool needsRebalance = false;
        for (uint256 i = 0; i < strategy.targetAllocations.length; i++) {
            uint256 deviation = currentAllocations[i] > strategy.targetAllocations[i] 
                ? currentAllocations[i] - strategy.targetAllocations[i]
                : strategy.targetAllocations[i] - currentAllocations[i];
            
            if (deviation > strategy.rebalanceThreshold) {
                needsRebalance = true;
                break;
            }
        }
        
        if (!needsRebalance) {
            revert("No rebalancing needed");
        }
        
        // Calculate target values
        uint256[] memory targetValues = new uint256[](strategy.vaultIds.length);
        for (uint256 i = 0; i < strategy.targetAllocations.length; i++) {
            targetValues[i] = (totalValue * strategy.targetAllocations[i]) / 10000;
        }
        
        // Execute transfers
        _executeTransfers(strategy.vaultIds, currentValues, targetValues);
    }
    
    function _executeTransfers(
        uint256[] memory vaultIds,
        uint256[] memory currentValues,
        uint256[] memory targetValues
    ) internal {
        // Simple implementation: withdraw from over-allocated vaults and deposit to under-allocated ones
        for (uint256 i = 0; i < vaultIds.length; i++) {
            if (currentValues[i] > targetValues[i]) {
                uint256 excess = currentValues[i] - targetValues[i];
                if (excess > 0.001 ether) { // Minimum transfer threshold
                    // Emergency withdraw excess (simplified - would need proper implementation)
                    // savingsVault.emergencyWithdraw(vaultIds[i]);
                }
            }
        }
        
        // Deposit to under-allocated vaults
        for (uint256 i = 0; i < vaultIds.length; i++) {
            if (currentValues[i] < targetValues[i]) {
                uint256 deficit = targetValues[i] - currentValues[i];
                if (deficit > 0.001 ether && address(this).balance >= deficit) {
                    // savingsVault.deposit{value: deficit}(vaultIds[i]);
                }
            }
        }
    }
    
    function _getTotalStrategyValue(uint256 strategyId) internal view returns (uint256) {
        RebalanceStrategy memory strategy = strategies[strategyId];
        uint256 totalValue = 0;
        
        for (uint256 i = 0; i < strategy.vaultIds.length; i++) {
            (, uint256 balance,,,) = savingsVault.getVaultDetails(strategy.vaultIds[i]);
            totalValue += balance;
        }
        
        return totalValue;
    }
    
    function checkRebalanceNeeded(uint256 strategyId) external view validStrategy(strategyId) returns (bool, uint256[] memory) {
        RebalanceStrategy memory strategy = strategies[strategyId];
        
        if (!strategy.isActive) return (false, new uint256[](0));
        if (block.timestamp < strategy.lastRebalance + strategy.minRebalanceInterval) {
            return (false, new uint256[](0));
        }
        
        uint256 totalValue = _getTotalStrategyValue(strategyId);
        if (totalValue == 0) return (false, new uint256[](0));
        
        uint256[] memory currentAllocations = new uint256[](strategy.vaultIds.length);
        uint256[] memory deviations = new uint256[](strategy.vaultIds.length);
        bool needsRebalance = false;
        
        for (uint256 i = 0; i < strategy.vaultIds.length; i++) {
            (, uint256 balance,,,) = savingsVault.getVaultDetails(strategy.vaultIds[i]);
            currentAllocations[i] = (balance * 10000) / totalValue;
            
            deviations[i] = currentAllocations[i] > strategy.targetAllocations[i] 
                ? currentAllocations[i] - strategy.targetAllocations[i]
                : strategy.targetAllocations[i] - currentAllocations[i];
            
            if (deviations[i] > strategy.rebalanceThreshold) {
                needsRebalance = true;
            }
        }
        
        return (needsRebalance, deviations);
    }
    
    function updateStrategy(
        uint256 strategyId,
        uint256[] calldata newTargetAllocations,
        uint256 newRebalanceThreshold
    ) external validStrategy(strategyId) onlyStrategyOwner(strategyId) {
        RebalanceStrategy storage strategy = strategies[strategyId];
        require(newTargetAllocations.length == strategy.vaultIds.length, "Array length mismatch");
        require(newRebalanceThreshold <= MAX_REBALANCE_THRESHOLD, "Threshold too high");
        
        uint256 totalAllocation = 0;
        for (uint256 i = 0; i < newTargetAllocations.length; i++) {
            totalAllocation += newTargetAllocations[i];
        }
        require(totalAllocation == 10000, "Allocations must sum to 100%");
        
        strategy.targetAllocations = newTargetAllocations;
        strategy.rebalanceThreshold = newRebalanceThreshold;
        
        emit StrategyUpdated(strategyId, newTargetAllocations);
    }
    
    function deactivateStrategy(uint256 strategyId) external validStrategy(strategyId) onlyStrategyOwner(strategyId) {
        strategies[strategyId].isActive = false;
        emit StrategyDeactivated(strategyId);
    }
    
    function getStrategy(uint256 strategyId) external view validStrategy(strategyId) returns (RebalanceStrategy memory) {
        return strategies[strategyId];
    }
    
    function getUserStrategies(address user) external view returns (uint256[] memory) {
        return userStrategies[user];
    }
    
    function getExecutionHistory(uint256 strategyId) external view returns (RebalanceExecution[] memory) {
        return executionHistory[strategyId];
    }
    
    function setRebalanceFee(uint256 newFee) external onlyOwner {
        rebalanceFee = newFee;
    }
    
    function withdrawFees() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    receive() external payable {}
}
