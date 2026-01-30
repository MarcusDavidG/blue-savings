// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title MultiSigGovernance
 * @dev Multi-signature governance for protocol upgrades and parameter changes
 */
contract MultiSigGovernance is Ownable, ReentrancyGuard {
    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string description;
        bytes callData;
        address target;
        uint256 value;
        uint256 createdAt;
        uint256 executionTime;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
        bool cancelled;
        ProposalType proposalType;
    }
    
    enum ProposalType {
        PARAMETER_CHANGE,
        UPGRADE,
        EMERGENCY_ACTION,
        TREASURY_ACTION
    }
    
    struct Vote {
        bool hasVoted;
        bool support;
        uint256 timestamp;
        string reason;
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => Vote)) public votes;
    mapping(address => bool) public governors;
    mapping(address => uint256) public governorWeights;
    
    uint256 public proposalCounter;
    uint256 public totalGovernorWeight;
    uint256 public quorumThreshold = 6000; // 60%
    uint256 public votingPeriod = 3 days;
    uint256 public executionDelay = 1 days;
    uint256 public gracePeriod = 14 days;
    
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string title,
        ProposalType proposalType
    );
    event VoteCast(
        uint256 indexed proposalId,
        address indexed voter,
        bool support,
        uint256 weight,
        string reason
    );
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCancelled(uint256 indexed proposalId);
    event GovernorAdded(address indexed governor, uint256 weight);
    event GovernorRemoved(address indexed governor);
    event QuorumThresholdUpdated(uint256 newThreshold);
    
    modifier onlyGovernor() {
        require(governors[msg.sender], "Not a governor");
        _;
    }
    
    modifier validProposal(uint256 proposalId) {
        require(proposalId > 0 && proposalId <= proposalCounter, "Invalid proposal");
        _;
    }
    
    constructor(
        address[] memory _governors,
        uint256[] memory _weights
    ) Ownable(msg.sender) {
        require(_governors.length == _weights.length, "Array length mismatch");
        require(_governors.length >= 3, "Minimum 3 governors required");
        
        for (uint256 i = 0; i < _governors.length; i++) {
            require(_governors[i] != address(0), "Invalid governor address");
            require(_weights[i] > 0, "Weight must be positive");
            
            governors[_governors[i]] = true;
            governorWeights[_governors[i]] = _weights[i];
            totalGovernorWeight += _weights[i];
        }
    }
    
    function createProposal(
        string calldata title,
        string calldata description,
        address target,
        uint256 value,
        bytes calldata callData,
        ProposalType proposalType
    ) external onlyGovernor returns (uint256) {
        require(bytes(title).length > 0, "Title required");
        require(target != address(0), "Invalid target");
        
        uint256 proposalId = ++proposalCounter;
        
        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            title: title,
            description: description,
            callData: callData,
            target: target,
            value: value,
            createdAt: block.timestamp,
            executionTime: 0,
            votesFor: 0,
            votesAgainst: 0,
            executed: false,
            cancelled: false,
            proposalType: proposalType
        });
        
        emit ProposalCreated(proposalId, msg.sender, title, proposalType);
        return proposalId;
    }
    
    function vote(
        uint256 proposalId,
        bool support,
        string calldata reason
    ) external onlyGovernor validProposal(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        require(block.timestamp <= proposal.createdAt + votingPeriod, "Voting period ended");
        
        Vote storage voterVote = votes[proposalId][msg.sender];
        require(!voterVote.hasVoted, "Already voted");
        
        uint256 weight = governorWeights[msg.sender];
        
        voterVote.hasVoted = true;
        voterVote.support = support;
        voterVote.timestamp = block.timestamp;
        voterVote.reason = reason;
        
        if (support) {
            proposal.votesFor += weight;
        } else {
            proposal.votesAgainst += weight;
        }
        
        emit VoteCast(proposalId, msg.sender, support, weight, reason);
        
        // Check if proposal can be queued for execution
        if (_hasReachedQuorum(proposalId) && _isPassing(proposalId)) {
            proposal.executionTime = block.timestamp + executionDelay;
        }
    }
    
    function executeProposal(uint256 proposalId) external validProposal(proposalId) nonReentrant {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Proposal cancelled");
        require(proposal.executionTime > 0, "Not queued for execution");
        require(block.timestamp >= proposal.executionTime, "Execution delay not met");
        require(block.timestamp <= proposal.executionTime + gracePeriod, "Grace period expired");
        require(_hasReachedQuorum(proposalId), "Quorum not reached");
        require(_isPassing(proposalId), "Proposal not passing");
        
        proposal.executed = true;
        
        (bool success, bytes memory returnData) = proposal.target.call{value: proposal.value}(proposal.callData);
        require(success, string(returnData));
        
        emit ProposalExecuted(proposalId);
    }
    
    function cancelProposal(uint256 proposalId) external validProposal(proposalId) {
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Already executed");
        require(!proposal.cancelled, "Already cancelled");
        require(
            msg.sender == proposal.proposer || msg.sender == owner(),
            "Not authorized to cancel"
        );
        
        proposal.cancelled = true;
        emit ProposalCancelled(proposalId);
    }
    
    function addGovernor(address governor, uint256 weight) external onlyOwner {
        require(governor != address(0), "Invalid address");
        require(weight > 0, "Weight must be positive");
        require(!governors[governor], "Already a governor");
        
        governors[governor] = true;
        governorWeights[governor] = weight;
        totalGovernorWeight += weight;
        
        emit GovernorAdded(governor, weight);
    }
    
    function removeGovernor(address governor) external onlyOwner {
        require(governors[governor], "Not a governor");
        
        governors[governor] = false;
        totalGovernorWeight -= governorWeights[governor];
        governorWeights[governor] = 0;
        
        emit GovernorRemoved(governor);
    }
    
    function updateQuorumThreshold(uint256 newThreshold) external onlyOwner {
        require(newThreshold > 0 && newThreshold <= 10000, "Invalid threshold");
        quorumThreshold = newThreshold;
        emit QuorumThresholdUpdated(newThreshold);
    }
    
    function getProposal(uint256 proposalId) external view validProposal(proposalId) returns (Proposal memory) {
        return proposals[proposalId];
    }
    
    function getVote(uint256 proposalId, address voter) external view returns (Vote memory) {
        return votes[proposalId][voter];
    }
    
    function getProposalState(uint256 proposalId) external view validProposal(proposalId) returns (string memory) {
        Proposal memory proposal = proposals[proposalId];
        
        if (proposal.cancelled) return "Cancelled";
        if (proposal.executed) return "Executed";
        if (block.timestamp <= proposal.createdAt + votingPeriod) return "Active";
        if (!_hasReachedQuorum(proposalId)) return "Failed (No Quorum)";
        if (!_isPassing(proposalId)) return "Failed (Rejected)";
        if (proposal.executionTime == 0) return "Succeeded";
        if (block.timestamp < proposal.executionTime) return "Queued";
        if (block.timestamp <= proposal.executionTime + gracePeriod) return "Executable";
        return "Expired";
    }
    
    function _hasReachedQuorum(uint256 proposalId) internal view returns (bool) {
        Proposal memory proposal = proposals[proposalId];
        uint256 totalVotes = proposal.votesFor + proposal.votesAgainst;
        uint256 requiredQuorum = (totalGovernorWeight * quorumThreshold) / 10000;
        return totalVotes >= requiredQuorum;
    }
    
    function _isPassing(uint256 proposalId) internal view returns (bool) {
        Proposal memory proposal = proposals[proposalId];
        return proposal.votesFor > proposal.votesAgainst;
    }
    
    // Emergency functions
    function emergencyExecute(
        address target,
        bytes calldata callData
    ) external onlyOwner nonReentrant {
        (bool success, bytes memory returnData) = target.call(callData);
        require(success, string(returnData));
    }
    
    receive() external payable {}
}
