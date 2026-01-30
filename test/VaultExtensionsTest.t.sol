// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/analytics/VaultAnalytics.sol";
import "../src/risk/RiskAssessment.sol";
import "../src/security/EmergencyPause.sol";
import "../src/insurance/VaultInsurance.sol";
import "../src/yield/AdvancedYieldFarming.sol";

contract VaultAnalyticsTest is Test {
    VaultAnalytics analytics;
    address mockSavingsVault = address(0x123);
    
    function setUp() public {
        analytics = new VaultAnalytics(mockSavingsVault);
    }
    
    function testUpdateVaultMetrics() public {
        uint256 vaultId = 1;
        
        analytics.updateVaultMetrics(vaultId);
        
        VaultAnalytics.VaultMetrics memory metrics = analytics.getVaultPerformance(vaultId);
        assertEq(metrics.lastUpdated, block.timestamp);
    }
    
    function testGetVaultPerformance() public {
        uint256 vaultId = 1;
        
        VaultAnalytics.VaultMetrics memory metrics = analytics.getVaultPerformance(vaultId);
        assertEq(metrics.totalDeposits, 0);
        assertEq(metrics.totalWithdrawals, 0);
        assertEq(metrics.averageHoldTime, 0);
        assertEq(metrics.successRate, 0);
    }
}

contract RiskAssessmentTest is Test {
    RiskAssessment riskAssessment;
    
    function setUp() public {
        riskAssessment = new RiskAssessment();
    }
    
    function testAssessLowRiskVault() public {
        uint256 vaultId = 1;
        uint256 amount = 0.5 ether;
        uint256 lockTime = 7 days;
        bool hasGoal = false;
        
        RiskAssessment.RiskLevel level = riskAssessment.assessVaultRisk(
            vaultId, amount, lockTime, hasGoal
        );
        
        assertEq(uint256(level), uint256(RiskAssessment.RiskLevel.LOW));
    }
    
    function testAssessHighRiskVault() public {
        uint256 vaultId = 1;
        uint256 amount = 15 ether;
        uint256 lockTime = 400 days;
        bool hasGoal = true;
        
        RiskAssessment.RiskLevel level = riskAssessment.assessVaultRisk(
            vaultId, amount, lockTime, hasGoal
        );
        
        assertEq(uint256(level), uint256(RiskAssessment.RiskLevel.CRITICAL));
    }
    
    function testRiskThresholds() public {
        assertEq(riskAssessment.riskThresholds(RiskAssessment.RiskLevel.LOW), 25);
        assertEq(riskAssessment.riskThresholds(RiskAssessment.RiskLevel.MEDIUM), 50);
        assertEq(riskAssessment.riskThresholds(RiskAssessment.RiskLevel.HIGH), 75);
        assertEq(riskAssessment.riskThresholds(RiskAssessment.RiskLevel.CRITICAL), 100);
    }
}

contract EmergencyPauseTest is Test {
    EmergencyPause emergencyPause;
    address operator = address(0x456);
    
    function setUp() public {
        emergencyPause = new EmergencyPause();
        emergencyPause.addEmergencyOperator(operator);
    }
    
    function testAddEmergencyOperator() public {
        address newOperator = address(0x789);
        emergencyPause.addEmergencyOperator(newOperator);
        assertTrue(emergencyPause.emergencyOperators(newOperator));
    }
    
    function testEmergencyPause() public {
        vm.prank(operator);
        emergencyPause.emergencyPause("Test emergency");
        
        assertTrue(emergencyPause.isPaused());
        assertEq(emergencyPause.pauseStartTime(), block.timestamp);
    }
    
    function testEmergencyUnpause() public {
        vm.prank(operator);
        emergencyPause.emergencyPause("Test emergency");
        
        emergencyPause.emergencyUnpause();
        assertFalse(emergencyPause.isPaused());
        assertEq(emergencyPause.pauseStartTime(), 0);
    }
    
    function testForceUnpause() public {
        vm.prank(operator);
        emergencyPause.emergencyPause("Test emergency");
        
        // Fast forward past max pause duration
        vm.warp(block.timestamp + 8 days);
        
        emergencyPause.forceUnpause();
        assertFalse(emergencyPause.isPaused());
    }
    
    function testPauseDeposits() public {
        vm.prank(operator);
        emergencyPause.pauseDeposits();
        assertTrue(emergencyPause.isDepositsPaused());
    }
    
    function testPauseWithdrawals() public {
        vm.prank(operator);
        emergencyPause.pauseWithdrawals();
        assertTrue(emergencyPause.isWithdrawalsPaused());
    }
}

contract VaultInsuranceTest is Test {
    VaultInsurance insurance;
    uint256 vaultId = 1;
    
    function setUp() public {
        insurance = new VaultInsurance();
        // Fund the insurance contract
        vm.deal(address(this), 100 ether);
        insurance.depositToFund{value: 10 ether}();
    }
    
    function testDepositToFund() public {
        uint256 initialFund = insurance.totalInsuranceFund();
        insurance.depositToFund{value: 5 ether}();
        assertEq(insurance.totalInsuranceFund(), initialFund + 5 ether);
    }
    
    function testCreatePolicy() public {
        uint256 coverage = 1 ether;
        uint256 duration = 365 days;
        uint256 premium = insurance.calculatePremium(coverage, duration);
        
        insurance.createPolicy{value: premium}(vaultId, coverage, duration);
        
        (uint256 policyCoverage, uint256 policyPremium, uint256 startTime, uint256 endTime, bool isActive, bool hasClaimed) = 
            insurance.vaultPolicies(vaultId);
        
        assertEq(policyCoverage, coverage);
        assertEq(policyPremium, premium);
        assertEq(startTime, block.timestamp);
        assertEq(endTime, block.timestamp + duration);
        assertTrue(isActive);
        assertFalse(hasClaimed);
    }
    
    function testSubmitClaim() public {
        uint256 coverage = 1 ether;
        uint256 duration = 365 days;
        uint256 premium = insurance.calculatePremium(coverage, duration);
        
        insurance.createPolicy{value: premium}(vaultId, coverage, duration);
        
        uint256 claimAmount = 0.5 ether;
        uint256 claimId = insurance.submitClaim(vaultId, claimAmount, "Test claim");
        
        (uint256 claimVaultId, uint256 amount, string memory reason, uint256 timestamp, bool isApproved, bool isPaid) = 
            insurance.claims(claimId);
        
        assertEq(claimVaultId, vaultId);
        assertEq(amount, claimAmount);
        assertEq(keccak256(bytes(reason)), keccak256(bytes("Test claim")));
        assertEq(timestamp, block.timestamp);
        assertFalse(isApproved);
        assertFalse(isPaid);
    }
    
    function testCalculatePremium() public {
        uint256 coverage = 1 ether;
        uint256 duration = 365 days;
        uint256 expectedPremium = (coverage * 100 * duration) / (10000 * 365 days);
        
        uint256 actualPremium = insurance.calculatePremium(coverage, duration);
        assertEq(actualPremium, expectedPremium);
    }
    
    function testGetAvailableCoverage() public {
        uint256 totalFund = insurance.totalInsuranceFund();
        uint256 maxCoverage = (totalFund * 8000) / 10000;
        uint256 currentCoverage = insurance.totalCoverage();
        uint256 expectedAvailable = maxCoverage - currentCoverage;
        
        uint256 actualAvailable = insurance.getAvailableCoverage();
        assertEq(actualAvailable, expectedAvailable);
    }
}

contract AdvancedYieldFarmingTest is Test {
    AdvancedYieldFarming farming;
    address protocol = address(0xABC);
    
    function setUp() public {
        farming = new AdvancedYieldFarming();
        vm.deal(address(this), 100 ether);
    }
    
    function testAddStrategy() public {
        uint256 apy = 500; // 5%
        uint256 riskScore = 30;
        
        uint256 strategyId = farming.addStrategy(protocol, apy, riskScore);
        
        (address strategyProtocol, uint256 strategyApy, uint256 tvl, uint256 strategyRiskScore, bool isActive, uint256 lastUpdated) = 
            farming.strategies(strategyId);
        
        assertEq(strategyProtocol, protocol);
        assertEq(strategyApy, apy);
        assertEq(tvl, 0);
        assertEq(strategyRiskScore, riskScore);
        assertTrue(isActive);
        assertEq(lastUpdated, block.timestamp);
    }
    
    function testOpenPosition() public {
        uint256 strategyId = farming.addStrategy(protocol, 500, 30);
        uint256 depositAmount = 1 ether;
        
        farming.openPosition{value: depositAmount}(strategyId);
        
        (uint256 positionStrategyId, uint256 principal, uint256 rewards, uint256 lastCompound, uint256 startTime) = 
            farming.positions(strategyId, address(this));
        
        assertEq(positionStrategyId, 0); // Default value
        assertEq(principal, depositAmount);
        assertEq(rewards, 0);
        assertEq(lastCompound, block.timestamp);
        assertEq(startTime, block.timestamp);
    }
    
    function testCalculateRewards() public {
        uint256 strategyId = farming.addStrategy(protocol, 1000, 30); // 10% APY
        uint256 depositAmount = 1 ether;
        
        farming.openPosition{value: depositAmount}(strategyId);
        
        // Fast forward 30 days
        vm.warp(block.timestamp + 30 days);
        
        uint256 rewards = farming.calculateRewards(strategyId, address(this));
        uint256 expectedRewards = (depositAmount * 1000 * 30 days) / (10000 * 365 days);
        
        assertEq(rewards, expectedRewards);
    }
    
    function testGetBestStrategy() public {
        farming.addStrategy(protocol, 300, 20); // 3% APY
        farming.addStrategy(address(0xDEF), 800, 40); // 8% APY
        farming.addStrategy(address(0x456), 600, 30); // 6% APY
        
        (uint256 bestId, uint256 bestApy) = farming.getBestStrategy();
        
        assertEq(bestId, 2); // Second strategy has highest APY
        assertEq(bestApy, 800);
    }
    
    function testUpdateStrategy() public {
        uint256 strategyId = farming.addStrategy(protocol, 500, 30);
        uint256 newApy = 700;
        uint256 newRiskScore = 40;
        
        farming.updateStrategy(strategyId, newApy, newRiskScore);
        
        (, uint256 apy, , uint256 riskScore, , uint256 lastUpdated) = farming.strategies(strategyId);
        
        assertEq(apy, newApy);
        assertEq(riskScore, newRiskScore);
        assertEq(lastUpdated, block.timestamp);
    }
}
