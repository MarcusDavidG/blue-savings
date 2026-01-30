// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultInsurance
 * @dev Insurance mechanism for vault deposits with premium collection
 */
contract VaultInsurance {
    struct InsurancePolicy {
        uint256 coverageAmount;
        uint256 premiumPaid;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool hasClaimed;
    }
    
    struct InsurancePool {
        uint256 totalPremiums;
        uint256 totalClaims;
        uint256 availableFunds;
        uint256 reserveRatio; // Percentage of funds to keep in reserve
    }
    
    mapping(uint256 => InsurancePolicy) public vaultPolicies;
    mapping(address => uint256[]) public userPolicies;
    
    InsurancePool public pool;
    address public owner;
    address public savingsVault;
    
    uint256 public constant PREMIUM_RATE = 50; // 0.5% annual premium
    uint256 public constant MAX_COVERAGE_RATIO = 8000; // 80% of deposit
    uint256 public constant CLAIM_WAITING_PERIOD = 48 hours;
    
    event PolicyCreated(uint256 indexed vaultId, uint256 coverageAmount, uint256 premium);
    event ClaimSubmitted(uint256 indexed vaultId, uint256 claimAmount);
    event ClaimPaid(uint256 indexed vaultId, uint256 amount);
    event PremiumCollected(uint256 indexed vaultId, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender == savingsVault, "Only vault can call");
        _;
    }
    
    constructor(address _savingsVault) {
        owner = msg.sender;
        savingsVault = _savingsVault;
        pool.reserveRatio = 2000; // 20% reserve ratio
    }
    
    function createPolicy(
        uint256 vaultId,
        uint256 depositAmount,
        address user,
        uint256 duration
    ) external payable onlyVault {
        require(duration >= 30 days && duration <= 365 days, "Invalid duration");
        
        uint256 maxCoverage = (depositAmount * MAX_COVERAGE_RATIO) / 10000;
        uint256 coverageAmount = msg.value > maxCoverage ? maxCoverage : depositAmount;
        
        uint256 annualPremium = (coverageAmount * PREMIUM_RATE) / 10000;
        uint256 premium = (annualPremium * duration) / 365 days;
        
        require(msg.value >= premium, "Insufficient premium");
        
        vaultPolicies[vaultId] = InsurancePolicy({
            coverageAmount: coverageAmount,
            premiumPaid: premium,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            hasClaimed: false
        });
        
        userPolicies[user].push(vaultId);
        
        pool.totalPremiums += premium;
        pool.availableFunds += premium;
        
        // Refund excess payment
        if (msg.value > premium) {
            payable(msg.sender).transfer(msg.value - premium);
        }
        
        emit PolicyCreated(vaultId, coverageAmount, premium);
        emit PremiumCollected(vaultId, premium);
    }
    
    function submitClaim(uint256 vaultId, uint256 lossAmount) external {
        InsurancePolicy storage policy = vaultPolicies[vaultId];
        require(policy.isActive, "Policy not active");
        require(!policy.hasClaimed, "Already claimed");
        require(block.timestamp <= policy.endTime, "Policy expired");
        require(block.timestamp >= policy.startTime + CLAIM_WAITING_PERIOD, "Waiting period not met");
        
        uint256 claimAmount = lossAmount > policy.coverageAmount ? policy.coverageAmount : lossAmount;
        require(claimAmount > 0, "No valid claim");
        
        uint256 availableForClaims = (pool.availableFunds * (10000 - pool.reserveRatio)) / 10000;
        require(claimAmount <= availableForClaims, "Insufficient pool funds");
        
        policy.hasClaimed = true;
        policy.isActive = false;
        
        pool.totalClaims += claimAmount;
        pool.availableFunds -= claimAmount;
        
        payable(msg.sender).transfer(claimAmount);
        
        emit ClaimSubmitted(vaultId, claimAmount);
        emit ClaimPaid(vaultId, claimAmount);
    }
    
    function renewPolicy(uint256 vaultId, uint256 additionalDuration) external payable {
        InsurancePolicy storage policy = vaultPolicies[vaultId];
        require(policy.isActive, "Policy not active");
        require(additionalDuration >= 30 days && additionalDuration <= 365 days, "Invalid duration");
        
        uint256 annualPremium = (policy.coverageAmount * PREMIUM_RATE) / 10000;
        uint256 renewalPremium = (annualPremium * additionalDuration) / 365 days;
        
        require(msg.value >= renewalPremium, "Insufficient premium");
        
        policy.endTime += additionalDuration;
        policy.premiumPaid += renewalPremium;
        
        pool.totalPremiums += renewalPremium;
        pool.availableFunds += renewalPremium;
        
        if (msg.value > renewalPremium) {
            payable(msg.sender).transfer(msg.value - renewalPremium);
        }
        
        emit PremiumCollected(vaultId, renewalPremium);
    }
    
    function getPoolStats() external view returns (
        uint256 totalPremiums,
        uint256 totalClaims,
        uint256 availableFunds,
        uint256 reserveAmount
    ) {
        return (
            pool.totalPremiums,
            pool.totalClaims,
            pool.availableFunds,
            (pool.availableFunds * pool.reserveRatio) / 10000
        );
    }
    
    function getPolicyDetails(uint256 vaultId) external view returns (InsurancePolicy memory) {
        return vaultPolicies[vaultId];
    }
    
    function getUserPolicies(address user) external view returns (uint256[] memory) {
        return userPolicies[user];
    }
    
    function updateReserveRatio(uint256 newRatio) external onlyOwner {
        require(newRatio <= 5000, "Reserve ratio too high"); // Max 50%
        pool.reserveRatio = newRatio;
    }
    
    function emergencyWithdraw() external onlyOwner {
        uint256 reserveAmount = (pool.availableFunds * pool.reserveRatio) / 10000;
        uint256 withdrawable = pool.availableFunds - reserveAmount;
        
        if (withdrawable > 0) {
            pool.availableFunds -= withdrawable;
            payable(owner).transfer(withdrawable);
        }
    }
}
