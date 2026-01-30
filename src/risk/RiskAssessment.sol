// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title RiskAssessment
 * @dev Risk scoring system for vault configurations
 */
contract RiskAssessment {
    enum RiskLevel { LOW, MEDIUM, HIGH, CRITICAL }
    
    struct RiskProfile {
        RiskLevel level;
        uint256 score;
        string[] factors;
        uint256 lastAssessed;
    }
    
    mapping(uint256 => RiskProfile) public vaultRisks;
    mapping(RiskLevel => uint256) public riskThresholds;
    
    event RiskAssessed(uint256 indexed vaultId, RiskLevel level, uint256 score);
    
    constructor() {
        riskThresholds[RiskLevel.LOW] = 25;
        riskThresholds[RiskLevel.MEDIUM] = 50;
        riskThresholds[RiskLevel.HIGH] = 75;
        riskThresholds[RiskLevel.CRITICAL] = 100;
    }
    
    function assessVaultRisk(
        uint256 vaultId,
        uint256 amount,
        uint256 lockTime,
        bool hasGoal
    ) external returns (RiskLevel) {
        uint256 score = calculateRiskScore(amount, lockTime, hasGoal);
        RiskLevel level = determineRiskLevel(score);
        
        vaultRisks[vaultId] = RiskProfile({
            level: level,
            score: score,
            factors: new string[](0),
            lastAssessed: block.timestamp
        });
        
        emit RiskAssessed(vaultId, level, score);
        return level;
    }
    
    function calculateRiskScore(
        uint256 amount,
        uint256 lockTime,
        bool hasGoal
    ) internal pure returns (uint256) {
        uint256 score = 0;
        
        // Amount risk (higher amounts = higher risk)
        if (amount > 10 ether) score += 30;
        else if (amount > 5 ether) score += 20;
        else if (amount > 1 ether) score += 10;
        
        // Lock time risk (longer locks = higher risk)
        if (lockTime > 365 days) score += 25;
        else if (lockTime > 180 days) score += 15;
        else if (lockTime > 30 days) score += 5;
        
        // Goal-based vaults have additional complexity
        if (hasGoal) score += 10;
        
        return score;
    }
    
    function determineRiskLevel(uint256 score) internal view returns (RiskLevel) {
        if (score >= riskThresholds[RiskLevel.CRITICAL]) return RiskLevel.CRITICAL;
        if (score >= riskThresholds[RiskLevel.HIGH]) return RiskLevel.HIGH;
        if (score >= riskThresholds[RiskLevel.MEDIUM]) return RiskLevel.MEDIUM;
        return RiskLevel.LOW;
    }
}
