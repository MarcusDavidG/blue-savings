// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultInsurance
 * @notice Optional insurance coverage for vaults
 */
contract VaultInsurance {
    struct Policy {
        uint256 vaultId;
        address owner;
        uint256 coverageAmount;
        uint256 premium;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
        bool claimed;
    }

    Policy[] public policies;
    mapping(uint256 => uint256) public vaultPolicy; // vaultId => policyId
    uint256 public insurancePool;
    address public admin;

    event PolicyPurchased(uint256 indexed policyId, uint256 indexed vaultId, uint256 coverage);
    event ClaimSubmitted(uint256 indexed policyId, uint256 amount);
    event ClaimPaid(uint256 indexed policyId, uint256 amount);

    constructor() {
        admin = msg.sender;
    }

    function purchasePolicy(uint256 vaultId, uint256 coverageAmount, uint256 duration) external payable returns (uint256 policyId) {
        uint256 premium = calculatePremium(coverageAmount, duration);
        require(msg.value >= premium, "Insufficient premium");

        policyId = policies.length;
        policies.push(Policy({
            vaultId: vaultId,
            owner: msg.sender,
            coverageAmount: coverageAmount,
            premium: premium,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            isActive: true,
            claimed: false
        }));

        vaultPolicy[vaultId] = policyId;
        insurancePool += premium;

        emit PolicyPurchased(policyId, vaultId, coverageAmount);
    }

    function calculatePremium(uint256 coverageAmount, uint256 duration) public pure returns (uint256) {
        // 1% annual premium rate
        return (coverageAmount * duration * 100) / (365 days * 10000);
    }

    function submitClaim(uint256 policyId, uint256 amount) external {
        Policy storage policy = policies[policyId];
        require(policy.owner == msg.sender, "Not owner");
        require(policy.isActive, "Not active");
        require(!policy.claimed, "Already claimed");
        require(block.timestamp <= policy.endTime, "Expired");
        require(amount <= policy.coverageAmount, "Exceeds coverage");

        emit ClaimSubmitted(policyId, amount);
    }

    function approveClaim(uint256 policyId, uint256 amount) external {
        require(msg.sender == admin, "Not admin");
        Policy storage policy = policies[policyId];

        policy.claimed = true;
        policy.isActive = false;

        payable(policy.owner).transfer(amount);
        emit ClaimPaid(policyId, amount);
    }
}
