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
    mapping(address => address) public delegates;
    mapping(address => uint256) public delegatedPower;

    event ProposalCreated(uint256 indexed proposalId, address proposer, string description);
    event VoteCast(address indexed voter, uint256 indexed proposalId, bool support, uint256 weight);
    event ProposalExecuted(uint256 indexed proposalId);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);

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

    /// @notice Delegate voting power to another address
    function delegate(address delegatee) external {
        address currentDelegate = delegates[msg.sender];
        uint256 delegatorBalance = votingPower[msg.sender];

        delegates[msg.sender] = delegatee;

        emit DelegateChanged(msg.sender, currentDelegate, delegatee);

        // Remove power from old delegate
        if (currentDelegate != address(0)) {
            uint256 oldPower = delegatedPower[currentDelegate];
            delegatedPower[currentDelegate] = oldPower - delegatorBalance;
            emit DelegateVotesChanged(currentDelegate, oldPower, delegatedPower[currentDelegate]);
        }

        // Add power to new delegate
        if (delegatee != address(0)) {
            uint256 oldPower = delegatedPower[delegatee];
            delegatedPower[delegatee] = oldPower + delegatorBalance;
            emit DelegateVotesChanged(delegatee, oldPower, delegatedPower[delegatee]);
        }
    }

    /// @notice Get total voting power including delegations
    function getVotes(address account) external view returns (uint256) {
        return votingPower[account] + delegatedPower[account];
    }
}
