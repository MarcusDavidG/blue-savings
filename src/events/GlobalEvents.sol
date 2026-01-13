// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title GlobalEvents
 * @notice Centralized event definitions for indexing
 */
interface GlobalEvents {
    // Vault Events
    event VaultCreated(uint256 indexed vaultId, address indexed owner, uint256 goalAmount, uint256 unlockTimestamp);
    event Deposited(uint256 indexed vaultId, address indexed depositor, uint256 amount, uint256 fee);
    event Withdrawn(uint256 indexed vaultId, address indexed owner, uint256 amount);
    event EmergencyWithdraw(uint256 indexed vaultId, address indexed owner, uint256 amount);

    // Token Events
    event TokenWhitelisted(address indexed token);
    event TokenDelisted(address indexed token);
    event TokenDeposited(uint256 indexed vaultId, address indexed token, uint256 amount);
    event TokenWithdrawn(uint256 indexed vaultId, address indexed token, uint256 amount);

    // Governance Events
    event ProposalCreated(uint256 indexed proposalId, address indexed proposer);
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId);

    // Fee Events
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event FeesCollected(address indexed collector, uint256 amount);
}
