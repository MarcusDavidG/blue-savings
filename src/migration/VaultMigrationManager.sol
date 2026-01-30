// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "../interfaces/ISavingsVault.sol";

/**
 * @title VaultMigrationManager
 * @dev Manages migration of vaults between contract versions
 */
contract VaultMigrationManager is Ownable, ReentrancyGuard {
    struct MigrationPlan {
        address sourceContract;
        address targetContract;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool isCompleted;
        uint256 migratedVaults;
        uint256 totalVaults;
        string version;
    }
    
    struct VaultMigration {
        uint256 sourceVaultId;
        uint256 targetVaultId;
        address owner;
        uint256 amount;
        uint256 timestamp;
        bool isCompleted;
        bytes32 migrationHash;
    }
    
    mapping(uint256 => MigrationPlan) public migrationPlans;
    mapping(bytes32 => VaultMigration) public vaultMigrations;
    mapping(address => mapping(uint256 => bool)) public vaultMigrated;
    mapping(address => uint256[]) public userMigrations;
    
    uint256 public migrationPlanCounter;
    uint256 public migrationFee = 0.001 ether;
    uint256 public constant MIGRATION_WINDOW = 30 days;
    
    event MigrationPlanCreated(
        uint256 indexed planId,
        address indexed sourceContract,
        address indexed targetContract,
        string version
    );
    event VaultMigrationStarted(
        bytes32 indexed migrationHash,
        address indexed user,
        uint256 sourceVaultId,
        uint256 amount
    );
    event VaultMigrationCompleted(
        bytes32 indexed migrationHash,
        uint256 targetVaultId
    );
    event MigrationPlanCompleted(uint256 indexed planId);
    
    modifier validMigrationPlan(uint256 planId) {
        require(planId > 0 && planId <= migrationPlanCounter, "Invalid migration plan");
        _;
    }
    
    modifier activeMigrationPlan(uint256 planId) {
        MigrationPlan memory plan = migrationPlans[planId];
        require(plan.isActive, "Migration plan not active");
        require(block.timestamp >= plan.startTime, "Migration not started");
        require(block.timestamp <= plan.endTime, "Migration period ended");
        _;
    }
    
    constructor() Ownable(msg.sender) {}
    
    function createMigrationPlan(
        address sourceContract,
        address targetContract,
        uint256 startTime,
        string calldata version
    ) external onlyOwner returns (uint256) {
        require(sourceContract != address(0), "Invalid source contract");
        require(targetContract != address(0), "Invalid target contract");
        require(sourceContract != targetContract, "Same contract addresses");
        require(startTime > block.timestamp, "Start time must be in future");
        
        uint256 planId = ++migrationPlanCounter;
        
        migrationPlans[planId] = MigrationPlan({
            sourceContract: sourceContract,
            targetContract: targetContract,
            startTime: startTime,
            endTime: startTime + MIGRATION_WINDOW,
            isActive: true,
            isCompleted: false,
            migratedVaults: 0,
            totalVaults: 0,
            version: version
        });
        
        emit MigrationPlanCreated(planId, sourceContract, targetContract, version);
        return planId;
    }
    
    function initiateVaultMigration(
        uint256 planId,
        uint256 sourceVaultId
    ) external payable validMigrationPlan(planId) activeMigrationPlan(planId) nonReentrant {
        require(msg.value >= migrationFee, "Insufficient migration fee");
        require(!vaultMigrated[msg.sender][sourceVaultId], "Vault already migrated");
        
        MigrationPlan storage plan = migrationPlans[planId];
        ISavingsVault sourceVault = ISavingsVault(plan.sourceContract);
        
        // Verify vault ownership and get vault details
        (
            address owner,
            uint256 balance,
            uint256 goalAmount,
            uint256 unlockTimestamp,
            string memory name,
            string memory description
        ) = sourceVault.getVaultDetails(sourceVaultId);
        
        require(owner == msg.sender, "Not vault owner");
        require(balance > 0, "Empty vault");
        
        // Create migration record
        bytes32 migrationHash = keccak256(
            abi.encodePacked(
                msg.sender,
                sourceVaultId,
                planId,
                block.timestamp
            )
        );
        
        vaultMigrations[migrationHash] = VaultMigration({
            sourceVaultId: sourceVaultId,
            targetVaultId: 0, // Will be set when migration completes
            owner: msg.sender,
            amount: balance,
            timestamp: block.timestamp,
            isCompleted: false,
            migrationHash: migrationHash
        });
        
        userMigrations[msg.sender].push(sourceVaultId);
        vaultMigrated[msg.sender][sourceVaultId] = true;
        
        // Initiate withdrawal from source vault
        sourceVault.emergencyWithdraw(sourceVaultId);
        
        emit VaultMigrationStarted(migrationHash, msg.sender, sourceVaultId, balance);
        
        // Refund excess fee
        if (msg.value > migrationFee) {
            payable(msg.sender).transfer(msg.value - migrationFee);
        }
    }
    
    function completeMigration(
        bytes32 migrationHash,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string calldata name,
        string calldata description
    ) external payable nonReentrant {
        VaultMigration storage migration = vaultMigrations[migrationHash];
        require(migration.owner == msg.sender, "Not migration owner");
        require(!migration.isCompleted, "Migration already completed");
        require(msg.value >= migration.amount, "Insufficient funds for migration");
        
        // Find the active migration plan for this migration
        uint256 activePlanId = 0;
        for (uint256 i = 1; i <= migrationPlanCounter; i++) {
            MigrationPlan memory plan = migrationPlans[i];
            if (plan.isActive && !plan.isCompleted) {
                activePlanId = i;
                break;
            }
        }
        require(activePlanId > 0, "No active migration plan");
        
        MigrationPlan storage plan = migrationPlans[activePlanId];
        ISavingsVault targetVault = ISavingsVault(plan.targetContract);
        
        // Create new vault in target contract
        uint256 targetVaultId = targetVault.createVault{value: migration.amount}(
            goalAmount,
            unlockTimestamp,
            name,
            description
        );
        
        // Update migration record
        migration.targetVaultId = targetVaultId;
        migration.isCompleted = true;
        
        // Update plan statistics
        plan.migratedVaults++;
        
        emit VaultMigrationCompleted(migrationHash, targetVaultId);
        
        // Refund excess funds
        if (msg.value > migration.amount) {
            payable(msg.sender).transfer(msg.value - migration.amount);
        }
    }
    
    function batchMigrate(
        uint256 planId,
        uint256[] calldata sourceVaultIds,
        uint256[] calldata goalAmounts,
        uint256[] calldata unlockTimestamps,
        string[] calldata names,
        string[] calldata descriptions
    ) external payable validMigrationPlan(planId) activeMigrationPlan(planId) nonReentrant {
        require(sourceVaultIds.length == goalAmounts.length, "Array length mismatch");
        require(sourceVaultIds.length == unlockTimestamps.length, "Array length mismatch");
        require(sourceVaultIds.length == names.length, "Array length mismatch");
        require(sourceVaultIds.length == descriptions.length, "Array length mismatch");
        require(sourceVaultIds.length <= 10, "Too many vaults in batch");
        
        uint256 totalFee = migrationFee * sourceVaultIds.length;
        require(msg.value >= totalFee, "Insufficient migration fees");
        
        MigrationPlan storage plan = migrationPlans[planId];
        ISavingsVault sourceVault = ISavingsVault(plan.sourceContract);
        ISavingsVault targetVault = ISavingsVault(plan.targetContract);
        
        uint256 totalAmount = 0;
        
        // Process each vault
        for (uint256 i = 0; i < sourceVaultIds.length; i++) {
            uint256 sourceVaultId = sourceVaultIds[i];
            require(!vaultMigrated[msg.sender][sourceVaultId], "Vault already migrated");
            
            // Get vault details
            (
                address owner,
                uint256 balance,
                ,,,
            ) = sourceVault.getVaultDetails(sourceVaultId);
            
            require(owner == msg.sender, "Not vault owner");
            require(balance > 0, "Empty vault");
            
            totalAmount += balance;
            vaultMigrated[msg.sender][sourceVaultId] = true;
            
            // Emergency withdraw from source
            sourceVault.emergencyWithdraw(sourceVaultId);
        }
        
        require(msg.value >= totalFee + totalAmount, "Insufficient total funds");
        
        // Create new vaults in target contract
        for (uint256 i = 0; i < sourceVaultIds.length; i++) {
            (,uint256 balance,,,) = sourceVault.getVaultDetails(sourceVaultIds[i]);
            
            uint256 targetVaultId = targetVault.createVault{value: balance}(
                goalAmounts[i],
                unlockTimestamps[i],
                names[i],
                descriptions[i]
            );
            
            // Create migration record
            bytes32 migrationHash = keccak256(
                abi.encodePacked(
                    msg.sender,
                    sourceVaultIds[i],
                    planId,
                    block.timestamp,
                    i
                )
            );
            
            vaultMigrations[migrationHash] = VaultMigration({
                sourceVaultId: sourceVaultIds[i],
                targetVaultId: targetVaultId,
                owner: msg.sender,
                amount: balance,
                timestamp: block.timestamp,
                isCompleted: true,
                migrationHash: migrationHash
            });
            
            emit VaultMigrationCompleted(migrationHash, targetVaultId);
        }
        
        plan.migratedVaults += sourceVaultIds.length;
        
        // Refund excess funds
        uint256 totalRequired = totalFee + totalAmount;
        if (msg.value > totalRequired) {
            payable(msg.sender).transfer(msg.value - totalRequired);
        }
    }
    
    function completeMigrationPlan(uint256 planId) external onlyOwner validMigrationPlan(planId) {
        MigrationPlan storage plan = migrationPlans[planId];
        require(plan.isActive, "Plan not active");
        require(block.timestamp > plan.endTime, "Migration period not ended");
        
        plan.isActive = false;
        plan.isCompleted = true;
        
        emit MigrationPlanCompleted(planId);
    }
    
    function setMigrationFee(uint256 newFee) external onlyOwner {
        migrationFee = newFee;
    }
    
    function withdrawFees() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
    
    function getMigrationPlan(uint256 planId) external view validMigrationPlan(planId) returns (MigrationPlan memory) {
        return migrationPlans[planId];
    }
    
    function getUserMigrations(address user) external view returns (uint256[] memory) {
        return userMigrations[user];
    }
    
    function getMigrationProgress(uint256 planId) external view validMigrationPlan(planId) returns (uint256, uint256) {
        MigrationPlan memory plan = migrationPlans[planId];
        return (plan.migratedVaults, plan.totalVaults);
    }
}
