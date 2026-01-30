// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultGovernance
 * @dev Decentralized governance for protocol parameters and upgrades
 */
contract VaultGovernance {
    struct Proposal {
        uint256 id;
        address proposer;
        string title;
        string description;
        bytes callData;
        address target;
        uint256 value;
        uint256 startTime;
        uint256 endTime;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        bool executed;
        bool canceled;
        ProposalState state;
    }
    
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    
    struct GovernanceConfig {
        uint256 votingDelay;      // Delay before voting starts
        uint256 votingPeriod;     // Duration of voting
        uint256 proposalThreshold; // Min tokens to create proposal
        uint256 quorumVotes;      // Min votes for quorum
        uint256 timelockDelay;    // Delay before execution
    }
    
    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(uint256 => mapping(address => uint256)) public votes;
    mapping(address => uint256) public votingPower;
    
    uint256 public proposalCount;
    GovernanceConfig public config;
    address public owner;
    address public timelock;
    
    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string title,
        uint256 startTime,
        uint256 endTime
    );
    
    event VoteCast(
        address indexed voter,
        uint256 indexed proposalId,
        uint8 support,
        uint256 weight
    );
    
    event ProposalExecuted(uint256 indexed proposalId);
    event ProposalCanceled(uint256 indexed proposalId);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        
        // Default governance parameters
        config = GovernanceConfig({
            votingDelay: 1 days,
            votingPeriod: 7 days,
            proposalThreshold: 1000 ether, // 1000 ETH worth of voting power
            quorumVotes: 5000 ether,       // 5000 ETH worth for quorum
            timelockDelay: 2 days
        });
    }
    
    function propose(
        address target,
        uint256 value,
        bytes memory callData,
        string memory title,
        string memory description
    ) external returns (uint256) {
        require(votingPower[msg.sender] >= config.proposalThreshold, "Insufficient voting power");
        require(bytes(title).length > 0, "Title required");
        
        uint256 proposalId = ++proposalCount;
        uint256 startTime = block.timestamp + config.votingDelay;
        uint256 endTime = startTime + config.votingPeriod;
        
        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            title: title,
            description: description,
            callData: callData,
            target: target,
            value: value,
            startTime: startTime,
            endTime: endTime,
            forVotes: 0,
            againstVotes: 0,
            abstainVotes: 0,
            executed: false,
            canceled: false,
            state: ProposalState.Pending
        });
        
        emit ProposalCreated(proposalId, msg.sender, title, startTime, endTime);
        return proposalId;
    }
    
    function castVote(uint256 proposalId, uint8 support) external {
        require(support <= 2, "Invalid vote type");
        require(!hasVoted[proposalId][msg.sender], "Already voted");
        
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(block.timestamp >= proposal.startTime, "Voting not started");
        require(block.timestamp <= proposal.endTime, "Voting ended");
        
        uint256 weight = votingPower[msg.sender];
        require(weight > 0, "No voting power");
        
        hasVoted[proposalId][msg.sender] = true;
        votes[proposalId][msg.sender] = weight;
        
        if (support == 0) {
            proposal.againstVotes += weight;
        } else if (support == 1) {
            proposal.forVotes += weight;
        } else {
            proposal.abstainVotes += weight;
        }
        
        emit VoteCast(msg.sender, proposalId, support, weight);
    }
    
    function execute(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Proposal canceled");
        require(block.timestamp > proposal.endTime, "Voting not ended");
        
        // Check if proposal succeeded
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        require(totalVotes >= config.quorumVotes, "Quorum not reached");
        require(proposal.forVotes > proposal.againstVotes, "Proposal defeated");
        
        // Check timelock delay
        require(block.timestamp >= proposal.endTime + config.timelockDelay, "Timelock not expired");
        
        proposal.executed = true;
        proposal.state = ProposalState.Executed;
        
        // Execute the proposal
        if (proposal.target != address(0)) {
            (bool success,) = proposal.target.call{value: proposal.value}(proposal.callData);
            require(success, "Execution failed");
        }
        
        emit ProposalExecuted(proposalId);
    }
    
    function cancel(uint256 proposalId) external {
        Proposal storage proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        require(!proposal.executed, "Already executed");
        require(!proposal.canceled, "Already canceled");
        require(
            msg.sender == proposal.proposer || msg.sender == owner,
            "Not authorized to cancel"
        );
        
        proposal.canceled = true;
        proposal.state = ProposalState.Canceled;
        
        emit ProposalCanceled(proposalId);
    }
    
    function getProposalState(uint256 proposalId) external view returns (ProposalState) {
        Proposal memory proposal = proposals[proposalId];
        require(proposal.id != 0, "Proposal does not exist");
        
        if (proposal.canceled) return ProposalState.Canceled;
        if (proposal.executed) return ProposalState.Executed;
        
        if (block.timestamp < proposal.startTime) return ProposalState.Pending;
        if (block.timestamp <= proposal.endTime) return ProposalState.Active;
        
        uint256 totalVotes = proposal.forVotes + proposal.againstVotes + proposal.abstainVotes;
        if (totalVotes < config.quorumVotes || proposal.forVotes <= proposal.againstVotes) {
            return ProposalState.Defeated;
        }
        
        if (block.timestamp < proposal.endTime + config.timelockDelay) {
            return ProposalState.Queued;
        }
        
        return ProposalState.Succeeded;
    }
    
    function setVotingPower(address user, uint256 power) external onlyOwner {
        votingPower[user] = power;
    }
    
    function updateConfig(
        uint256 votingDelay,
        uint256 votingPeriod,
        uint256 proposalThreshold,
        uint256 quorumVotes,
        uint256 timelockDelay
    ) external onlyOwner {
        require(votingDelay <= 7 days, "Voting delay too long");
        require(votingPeriod >= 1 days && votingPeriod <= 30 days, "Invalid voting period");
        require(timelockDelay >= 1 days && timelockDelay <= 30 days, "Invalid timelock delay");
        
        config.votingDelay = votingDelay;
        config.votingPeriod = votingPeriod;
        config.proposalThreshold = proposalThreshold;
        config.quorumVotes = quorumVotes;
        config.timelockDelay = timelockDelay;
    }
    
    function getProposal(uint256 proposalId) external view returns (Proposal memory) {
        return proposals[proposalId];
    }
}
