// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultAudit
 * @dev Comprehensive audit trail and compliance tracking for vault operations
 */
contract VaultAudit {
    struct AuditEntry {
        uint256 id;
        uint256 vaultId;
        address user;
        AuditAction action;
        uint256 amount;
        uint256 timestamp;
        bytes32 transactionHash;
        string metadata;
        bytes additionalData;
    }
    
    enum AuditAction {
        VAULT_CREATED,
        DEPOSIT_MADE,
        WITHDRAWAL_MADE,
        EMERGENCY_WITHDRAWAL,
        GOAL_UPDATED,
        UNLOCK_TIME_UPDATED,
        METADATA_UPDATED,
        VAULT_TRANSFERRED,
        INSURANCE_CLAIMED,
        YIELD_EARNED,
        FEE_COLLECTED,
        GOVERNANCE_ACTION
    }
    
    struct ComplianceReport {
        uint256 totalVaults;
        uint256 totalDeposits;
        uint256 totalWithdrawals;
        uint256 totalFees;
        uint256 emergencyWithdrawals;
        uint256 reportTimestamp;
        bytes32 reportHash;
    }
    
    mapping(uint256 => AuditEntry[]) private vaultAuditTrail;
    mapping(address => AuditEntry[]) private userAuditTrail;
    mapping(bytes32 => bool) private processedTransactions;
    
    AuditEntry[] private globalAuditTrail;
    ComplianceReport[] private complianceReports;
    
    uint256 private auditCounter;
    address public owner;
    address public savingsVault;
    address public complianceOfficer;
    
    event AuditEntryCreated(
        uint256 indexed auditId,
        uint256 indexed vaultId,
        address indexed user,
        AuditAction action
    );
    
    event ComplianceReportGenerated(uint256 indexed reportId, bytes32 reportHash);
    event ComplianceOfficerUpdated(address indexed newOfficer);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender == savingsVault, "Only vault can call");
        _;
    }
    
    modifier onlyComplianceOfficer() {
        require(msg.sender == complianceOfficer || msg.sender == owner, "Not authorized");
        _;
    }
    
    constructor(address _savingsVault) {
        owner = msg.sender;
        savingsVault = _savingsVault;
        complianceOfficer = msg.sender;
    }
    
    /**
     * @dev Record audit entry for vault operation
     */
    function recordAuditEntry(
        uint256 vaultId,
        address user,
        AuditAction action,
        uint256 amount,
        string memory metadata,
        bytes memory additionalData
    ) external onlyVault {
        bytes32 txHash = keccak256(abi.encodePacked(
            block.timestamp,
            block.number,
            tx.origin,
            vaultId,
            user,
            action
        ));
        
        // Prevent duplicate entries for same transaction
        require(!processedTransactions[txHash], "Transaction already processed");
        processedTransactions[txHash] = true;
        
        uint256 auditId = ++auditCounter;
        
        AuditEntry memory entry = AuditEntry({
            id: auditId,
            vaultId: vaultId,
            user: user,
            action: action,
            amount: amount,
            timestamp: block.timestamp,
            transactionHash: txHash,
            metadata: metadata,
            additionalData: additionalData
        });
        
        // Store in multiple indices for efficient querying
        vaultAuditTrail[vaultId].push(entry);
        userAuditTrail[user].push(entry);
        globalAuditTrail.push(entry);
        
        emit AuditEntryCreated(auditId, vaultId, user, action);
    }
    
    /**
     * @dev Get audit trail for specific vault
     */
    function getVaultAuditTrail(uint256 vaultId) external view returns (AuditEntry[] memory) {
        return vaultAuditTrail[vaultId];
    }
    
    /**
     * @dev Get audit trail for specific user
     */
    function getUserAuditTrail(address user) external view returns (AuditEntry[] memory) {
        return userAuditTrail[user];
    }
    
    /**
     * @dev Get global audit trail with pagination
     */
    function getGlobalAuditTrail(uint256 offset, uint256 limit) 
        external 
        view 
        returns (AuditEntry[] memory) 
    {
        require(offset < globalAuditTrail.length, "Offset out of bounds");
        
        uint256 end = offset + limit;
        if (end > globalAuditTrail.length) {
            end = globalAuditTrail.length;
        }
        
        AuditEntry[] memory result = new AuditEntry[](end - offset);
        for (uint256 i = offset; i < end; i++) {
            result[i - offset] = globalAuditTrail[i];
        }
        
        return result;
    }
    
    /**
     * @dev Search audit entries by action type
     */
    function searchByAction(AuditAction action, uint256 limit) 
        external 
        view 
        returns (AuditEntry[] memory) 
    {
        AuditEntry[] memory results = new AuditEntry[](limit);
        uint256 count = 0;
        
        for (uint256 i = globalAuditTrail.length; i > 0 && count < limit; i--) {
            if (globalAuditTrail[i - 1].action == action) {
                results[count] = globalAuditTrail[i - 1];
                count++;
            }
        }
        
        // Resize array to actual count
        assembly {
            mstore(results, count)
        }
        
        return results;
    }
    
    /**
     * @dev Search audit entries by time range
     */
    function searchByTimeRange(
        uint256 startTime,
        uint256 endTime,
        uint256 limit
    ) external view returns (AuditEntry[] memory) {
        require(startTime <= endTime, "Invalid time range");
        
        AuditEntry[] memory results = new AuditEntry[](limit);
        uint256 count = 0;
        
        for (uint256 i = 0; i < globalAuditTrail.length && count < limit; i++) {
            if (globalAuditTrail[i].timestamp >= startTime && 
                globalAuditTrail[i].timestamp <= endTime) {
                results[count] = globalAuditTrail[i];
                count++;
            }
        }
        
        // Resize array to actual count
        assembly {
            mstore(results, count)
        }
        
        return results;
    }
    
    /**
     * @dev Generate compliance report
     */
    function generateComplianceReport() external onlyComplianceOfficer returns (uint256) {
        uint256 totalVaults = 0;
        uint256 totalDeposits = 0;
        uint256 totalWithdrawals = 0;
        uint256 totalFees = 0;
        uint256 emergencyWithdrawals = 0;
        
        // Analyze audit trail
        for (uint256 i = 0; i < globalAuditTrail.length; i++) {
            AuditEntry memory entry = globalAuditTrail[i];
            
            if (entry.action == AuditAction.VAULT_CREATED) {
                totalVaults++;
            } else if (entry.action == AuditAction.DEPOSIT_MADE) {
                totalDeposits += entry.amount;
            } else if (entry.action == AuditAction.WITHDRAWAL_MADE) {
                totalWithdrawals += entry.amount;
            } else if (entry.action == AuditAction.EMERGENCY_WITHDRAWAL) {
                emergencyWithdrawals++;
                totalWithdrawals += entry.amount;
            } else if (entry.action == AuditAction.FEE_COLLECTED) {
                totalFees += entry.amount;
            }
        }
        
        bytes32 reportHash = keccak256(abi.encodePacked(
            totalVaults,
            totalDeposits,
            totalWithdrawals,
            totalFees,
            emergencyWithdrawals,
            block.timestamp
        ));
        
        ComplianceReport memory report = ComplianceReport({
            totalVaults: totalVaults,
            totalDeposits: totalDeposits,
            totalWithdrawals: totalWithdrawals,
            totalFees: totalFees,
            emergencyWithdrawals: emergencyWithdrawals,
            reportTimestamp: block.timestamp,
            reportHash: reportHash
        });
        
        complianceReports.push(report);
        
        emit ComplianceReportGenerated(complianceReports.length - 1, reportHash);
        return complianceReports.length - 1;
    }
    
    /**
     * @dev Get compliance report
     */
    function getComplianceReport(uint256 reportId) external view returns (ComplianceReport memory) {
        require(reportId < complianceReports.length, "Report not found");
        return complianceReports[reportId];
    }
    
    /**
     * @dev Get latest compliance report
     */
    function getLatestComplianceReport() external view returns (ComplianceReport memory) {
        require(complianceReports.length > 0, "No reports available");
        return complianceReports[complianceReports.length - 1];
    }
    
    /**
     * @dev Get audit statistics
     */
    function getAuditStatistics() external view returns (
        uint256 totalEntries,
        uint256 totalVaultsAudited,
        uint256 totalUsersAudited,
        uint256 totalReports
    ) {
        totalEntries = globalAuditTrail.length;
        totalReports = complianceReports.length;
        
        // Count unique vaults and users (simplified approach)
        // In production, you might want to use more efficient data structures
        totalVaultsAudited = auditCounter; // Approximation
        totalUsersAudited = auditCounter; // Approximation
    }
    
    /**
     * @dev Verify audit entry integrity
     */
    function verifyAuditEntry(uint256 auditId) external view returns (bool) {
        require(auditId <= auditCounter && auditId > 0, "Invalid audit ID");
        
        // Find the entry (simplified linear search)
        for (uint256 i = 0; i < globalAuditTrail.length; i++) {
            if (globalAuditTrail[i].id == auditId) {
                AuditEntry memory entry = globalAuditTrail[i];
                
                bytes32 expectedHash = keccak256(abi.encodePacked(
                    entry.timestamp,
                    entry.vaultId,
                    entry.user,
                    entry.action
                ));
                
                return processedTransactions[expectedHash];
            }
        }
        
        return false;
    }
    
    /**
     * @dev Update compliance officer
     */
    function updateComplianceOfficer(address newOfficer) external onlyOwner {
        require(newOfficer != address(0), "Invalid address");
        complianceOfficer = newOfficer;
        emit ComplianceOfficerUpdated(newOfficer);
    }
    
    /**
     * @dev Export audit data for external analysis
     */
    function exportAuditData(uint256 startIndex, uint256 count) 
        external 
        view 
        onlyComplianceOfficer 
        returns (bytes memory) 
    {
        require(startIndex < globalAuditTrail.length, "Start index out of bounds");
        
        uint256 endIndex = startIndex + count;
        if (endIndex > globalAuditTrail.length) {
            endIndex = globalAuditTrail.length;
        }
        
        AuditEntry[] memory exportData = new AuditEntry[](endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            exportData[i - startIndex] = globalAuditTrail[i];
        }
        
        return abi.encode(exportData);
    }
}
