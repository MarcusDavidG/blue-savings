// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultBackup
 * @dev Backup and recovery system for vault data and metadata
 */
contract VaultBackup {
    struct VaultBackup {
        uint256 vaultId;
        address owner;
        uint256 balance;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        string name;
        string description;
        uint256 backupTimestamp;
        bytes32 dataHash;
        bool isActive;
    }
    
    struct RecoveryRequest {
        uint256 requestId;
        address requester;
        uint256 vaultId;
        bytes32 backupHash;
        uint256 requestTimestamp;
        bool isApproved;
        bool isExecuted;
        address[] approvers;
    }
    
    mapping(uint256 => VaultBackup[]) private vaultBackups;
    mapping(address => uint256[]) private userBackups;
    mapping(uint256 => RecoveryRequest) private recoveryRequests;
    mapping(address => bool) public authorizedBackupOperators;
    
    uint256 private backupCounter;
    uint256 private recoveryCounter;
    address public owner;
    address public savingsVault;
    
    uint256 public constant BACKUP_RETENTION_PERIOD = 365 days;
    uint256 public constant RECOVERY_APPROVAL_THRESHOLD = 2;
    
    event BackupCreated(uint256 indexed vaultId, uint256 backupId, bytes32 dataHash);
    event RecoveryRequested(uint256 indexed requestId, address indexed requester, uint256 indexed vaultId);
    event RecoveryApproved(uint256 indexed requestId, address indexed approver);
    event RecoveryExecuted(uint256 indexed requestId, uint256 indexed vaultId);
    event BackupOperatorAdded(address indexed operator);
    event BackupOperatorRemoved(address indexed operator);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedBackupOperators[msg.sender] || msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender == savingsVault, "Only vault can call");
        _;
    }
    
    constructor(address _savingsVault) {
        owner = msg.sender;
        savingsVault = _savingsVault;
        authorizedBackupOperators[msg.sender] = true;
    }
    
    /**
     * @dev Create backup of vault data
     */
    function createBackup(
        uint256 vaultId,
        address vaultOwner,
        uint256 balance,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string memory name,
        string memory description
    ) external onlyVault {
        bytes32 dataHash = keccak256(abi.encodePacked(
            vaultId,
            vaultOwner,
            balance,
            goalAmount,
            unlockTimestamp,
            name,
            description,
            block.timestamp
        ));
        
        VaultBackup memory backup = VaultBackup({
            vaultId: vaultId,
            owner: vaultOwner,
            balance: balance,
            goalAmount: goalAmount,
            unlockTimestamp: unlockTimestamp,
            name: name,
            description: description,
            backupTimestamp: block.timestamp,
            dataHash: dataHash,
            isActive: true
        });
        
        vaultBackups[vaultId].push(backup);
        userBackups[vaultOwner].push(vaultId);
        
        emit BackupCreated(vaultId, backupCounter++, dataHash);
    }
    
    /**
     * @dev Get vault backup history
     */
    function getVaultBackups(uint256 vaultId) external view returns (VaultBackup[] memory) {
        return vaultBackups[vaultId];
    }
    
    /**
     * @dev Get latest backup for a vault
     */
    function getLatestBackup(uint256 vaultId) external view returns (VaultBackup memory) {
        VaultBackup[] memory backups = vaultBackups[vaultId];
        require(backups.length > 0, "No backups found");
        
        return backups[backups.length - 1];
    }
    
    /**
     * @dev Get user's backed up vaults
     */
    function getUserBackups(address user) external view returns (uint256[] memory) {
        return userBackups[user];
    }
    
    /**
     * @dev Request vault recovery
     */
    function requestRecovery(uint256 vaultId, bytes32 backupHash) external returns (uint256) {
        // Verify backup exists
        bool backupExists = false;
        VaultBackup[] memory backups = vaultBackups[vaultId];
        
        for (uint256 i = 0; i < backups.length; i++) {
            if (backups[i].dataHash == backupHash && backups[i].owner == msg.sender) {
                backupExists = true;
                break;
            }
        }
        
        require(backupExists, "Backup not found or not authorized");
        
        uint256 requestId = ++recoveryCounter;
        
        recoveryRequests[requestId] = RecoveryRequest({
            requestId: requestId,
            requester: msg.sender,
            vaultId: vaultId,
            backupHash: backupHash,
            requestTimestamp: block.timestamp,
            isApproved: false,
            isExecuted: false,
            approvers: new address[](0)
        });
        
        emit RecoveryRequested(requestId, msg.sender, vaultId);
        return requestId;
    }
    
    /**
     * @dev Approve recovery request
     */
    function approveRecovery(uint256 requestId) external onlyAuthorized {
        RecoveryRequest storage request = recoveryRequests[requestId];
        require(request.requestId != 0, "Request not found");
        require(!request.isExecuted, "Already executed");
        require(request.requestTimestamp + 7 days > block.timestamp, "Request expired");
        
        // Check if already approved by this operator
        for (uint256 i = 0; i < request.approvers.length; i++) {
            require(request.approvers[i] != msg.sender, "Already approved");
        }
        
        request.approvers.push(msg.sender);
        
        if (request.approvers.length >= RECOVERY_APPROVAL_THRESHOLD) {
            request.isApproved = true;
        }
        
        emit RecoveryApproved(requestId, msg.sender);
    }
    
    /**
     * @dev Execute approved recovery
     */
    function executeRecovery(uint256 requestId) external onlyAuthorized {
        RecoveryRequest storage request = recoveryRequests[requestId];
        require(request.requestId != 0, "Request not found");
        require(request.isApproved, "Not approved");
        require(!request.isExecuted, "Already executed");
        require(request.requestTimestamp + 30 days > block.timestamp, "Request expired");
        
        // Find the backup data
        VaultBackup memory backup;
        VaultBackup[] memory backups = vaultBackups[request.vaultId];
        
        for (uint256 i = 0; i < backups.length; i++) {
            if (backups[i].dataHash == request.backupHash) {
                backup = backups[i];
                break;
            }
        }
        
        require(backup.vaultId != 0, "Backup data not found");
        
        // Execute recovery through vault contract
        (bool success,) = savingsVault.call(
            abi.encodeWithSignature(
                "recoverVault(uint256,address,uint256,uint256,uint256,string,string)",
                backup.vaultId,
                backup.owner,
                backup.balance,
                backup.goalAmount,
                backup.unlockTimestamp,
                backup.name,
                backup.description
            )
        );
        
        require(success, "Recovery execution failed");
        
        request.isExecuted = true;
        
        emit RecoveryExecuted(requestId, request.vaultId);
    }
    
    /**
     * @dev Add authorized backup operator
     */
    function addBackupOperator(address operator) external onlyOwner {
        require(operator != address(0), "Invalid address");
        authorizedBackupOperators[operator] = true;
        emit BackupOperatorAdded(operator);
    }
    
    /**
     * @dev Remove authorized backup operator
     */
    function removeBackupOperator(address operator) external onlyOwner {
        authorizedBackupOperators[operator] = false;
        emit BackupOperatorRemoved(operator);
    }
    
    /**
     * @dev Clean up old backups
     */
    function cleanupOldBackups(uint256 vaultId) external onlyAuthorized {
        VaultBackup[] storage backups = vaultBackups[vaultId];
        uint256 cutoffTime = block.timestamp - BACKUP_RETENTION_PERIOD;
        
        uint256 writeIndex = 0;
        for (uint256 readIndex = 0; readIndex < backups.length; readIndex++) {
            if (backups[readIndex].backupTimestamp >= cutoffTime) {
                if (writeIndex != readIndex) {
                    backups[writeIndex] = backups[readIndex];
                }
                writeIndex++;
            }
        }
        
        // Resize array
        while (backups.length > writeIndex) {
            backups.pop();
        }
    }
    
    /**
     * @dev Get recovery request details
     */
    function getRecoveryRequest(uint256 requestId) external view returns (RecoveryRequest memory) {
        return recoveryRequests[requestId];
    }
    
    /**
     * @dev Verify backup integrity
     */
    function verifyBackup(uint256 vaultId, uint256 backupIndex) external view returns (bool) {
        VaultBackup[] memory backups = vaultBackups[vaultId];
        require(backupIndex < backups.length, "Invalid backup index");
        
        VaultBackup memory backup = backups[backupIndex];
        
        bytes32 computedHash = keccak256(abi.encodePacked(
            backup.vaultId,
            backup.owner,
            backup.balance,
            backup.goalAmount,
            backup.unlockTimestamp,
            backup.name,
            backup.description,
            backup.backupTimestamp
        ));
        
        return computedHash == backup.dataHash;
    }
    
    /**
     * @dev Export backup data for external storage
     */
    function exportBackup(uint256 vaultId, uint256 backupIndex) 
        external 
        view 
        returns (bytes memory) 
    {
        VaultBackup[] memory backups = vaultBackups[vaultId];
        require(backupIndex < backups.length, "Invalid backup index");
        
        return abi.encode(backups[backupIndex]);
    }
}
