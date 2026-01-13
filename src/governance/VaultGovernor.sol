// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultGovernor
 * @notice Governance for protocol parameter changes
 * @dev Simple governance with proposal and voting
 */
contract VaultGovernor {
    enum ProposalState { Pending, Active, Defeated, Succeeded, Executed, Cancelled }

    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 startBlock;
        uint256 endBlock;
        bool executed;
        bool cancelled;
    }

    uint256 public proposalCount;
    uint256 public votingDelay = 1; // 1 block
    uint256 public votingPeriod = 50400; // ~1 week
    uint256 public quorum = 100e18;

    mapping(uint256 => Proposal) public proposals;
    mapping(uint256 => mapping(address => bool)) public hasVoted;
    mapping(address => uint256) public votingPower;

    event ProposalCreated(uint256 indexed proposalId, address proposer, string description);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);

    error AlreadyVoted();
    error ProposalNotActive();
    error InsufficientVotingPower();

    function propose(string calldata description) external returns (uint256) {
        if (votingPower[msg.sender] == 0) revert InsufficientVotingPower();

        uint256 proposalId = proposalCount++;

        proposals[proposalId] = Proposal({
            id: proposalId,
            proposer: msg.sender,
            description: description,
            forVotes: 0,
            againstVotes: 0,
            startBlock: block.number + votingDelay,
            endBlock: block.number + votingDelay + votingPeriod,
            executed: false,
            cancelled: false
        });

        emit ProposalCreated(proposalId, msg.sender, description);
        return proposalId;
    }

    function castVote(uint256 proposalId, bool support) external {
        if (hasVoted[proposalId][msg.sender]) revert AlreadyVoted();
        if (state(proposalId) != ProposalState.Active) revert ProposalNotActive();

        uint256 weight = votingPower[msg.sender];
        hasVoted[proposalId][msg.sender] = true;

        if (support) {
            proposals[proposalId].forVotes += weight;
        } else {
            proposals[proposalId].againstVotes += weight;
        }

        emit VoteCast(msg.sender, proposalId, support, weight);
    }

    function state(uint256 proposalId) public view returns (ProposalState) {
        Proposal memory proposal = proposals[proposalId];

        if (proposal.cancelled) return ProposalState.Cancelled;
        if (proposal.executed) return ProposalState.Executed;
        if (block.number <= proposal.startBlock) return ProposalState.Pending;
        if (block.number <= proposal.endBlock) return ProposalState.Active;
        if (proposal.forVotes <= proposal.againstVotes || proposal.forVotes < quorum) {
            return ProposalState.Defeated;
        }
        return ProposalState.Succeeded;
    }

    function setVotingPower(address account, uint256 power) external {
        votingPower[account] = power;
    }
}
