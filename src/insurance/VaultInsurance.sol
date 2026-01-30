// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title VaultInsurance
 * @dev Insurance coverage for vault deposits
 */
contract VaultInsurance is Ownable, ReentrancyGuard {
    struct InsurancePolicy {
        uint256 coverage;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool hasClaimed;
    }
    
    struct ClaimRequest {
        uint256 vaultId;
        uint256 amount;
        string reason;
        uint256 timestamp;
        bool isApproved;
        bool isPaid;
    }
    
    mapping(uint256 => InsurancePolicy) public vaultPolicies;
    mapping(uint256 => ClaimRequest) public claims;
    
    uint256 public totalInsuranceFund;
    uint256 public totalCoverage;
    uint256 public claimCounter;
    
    uint256 public constant PREMIUM_RATE = 100; // 1% annual premium
    uint256 public constant MAX_COVERAGE_RATIO = 8000; // 80% of fund
    
    event PolicyCreated(uint256 indexed vaultId, uint256 coverage, uint256 premium);
    event ClaimSubmitted(uint256 indexed claimId, uint256 indexed vaultId, uint256 amount);
    event ClaimApproved(uint256 indexed claimId, uint256 amount);
    event ClaimPaid(uint256 indexed claimId, address indexed beneficiary, uint256 amount);
    event FundDeposited(address indexed depositor, uint256 amount);
    
    constructor() Ownable(msg.sender) {}
    
    function depositToFund() external payable {
        totalInsuranceFund += msg.value;
        emit FundDeposited(msg.sender, msg.value);
    }
    
    function createPolicy(
        uint256 vaultId,
        uint256 coverage,
        uint256 duration
    ) external payable {
        require(coverage > 0, "Coverage must be positive");
        require(duration >= 30 days, "Minimum 30 days coverage");
        require(totalCoverage + coverage <= (totalInsuranceFund * MAX_COVERAGE_RATIO) / 10000, "Insufficient fund capacity");
        
        uint256 premium = calculatePremium(coverage, duration);
        require(msg.value >= premium, "Insufficient premium payment");
        
        vaultPolicies[vaultId] = InsurancePolicy({
            coverage: coverage,
            premium: premium,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            hasClaimed: false
        });
        
        totalCoverage += coverage;
        totalInsuranceFund += premium;
        
        emit PolicyCreated(vaultId, coverage, premium);
        
        // Refund excess payment
        if (msg.value > premium) {
            payable(msg.sender).transfer(msg.value - premium);
        }
    }
    
    function submitClaim(
        uint256 vaultId,
        uint256 amount,
        string calldata reason
    ) external returns (uint256) {
        InsurancePolicy storage policy = vaultPolicies[vaultId];
        require(policy.isActive, "No active policy");
        require(block.timestamp <= policy.endTime, "Policy expired");
        require(!policy.hasClaimed, "Already claimed");
        require(amount <= policy.coverage, "Amount exceeds coverage");
        
        uint256 claimId = ++claimCounter;
        claims[claimId] = ClaimRequest({
            vaultId: vaultId,
            amount: amount,
            reason: reason,
            timestamp: block.timestamp,
            isApproved: false,
            isPaid: false
        });
        
        emit ClaimSubmitted(claimId, vaultId, amount);
        return claimId;
    }
    
    function approveClaim(uint256 claimId) external onlyOwner {
        ClaimRequest storage claim = claims[claimId];
        require(!claim.isApproved, "Already approved");
        require(!claim.isPaid, "Already paid");
        
        claim.isApproved = true;
        emit ClaimApproved(claimId, claim.amount);
    }
    
    function payClaim(uint256 claimId, address beneficiary) external onlyOwner nonReentrant {
        ClaimRequest storage claim = claims[claimId];
        require(claim.isApproved, "Not approved");
        require(!claim.isPaid, "Already paid");
        require(totalInsuranceFund >= claim.amount, "Insufficient funds");
        
        claim.isPaid = true;
        vaultPolicies[claim.vaultId].hasClaimed = true;
        totalInsuranceFund -= claim.amount;
        totalCoverage -= vaultPolicies[claim.vaultId].coverage;
        
        payable(beneficiary).transfer(claim.amount);
        emit ClaimPaid(claimId, beneficiary, claim.amount);
    }
    
    function calculatePremium(uint256 coverage, uint256 duration) public pure returns (uint256) {
        return (coverage * PREMIUM_RATE * duration) / (10000 * 365 days);
    }
    
    function getAvailableCoverage() external view returns (uint256) {
        return ((totalInsuranceFund * MAX_COVERAGE_RATIO) / 10000) - totalCoverage;
    }
}
