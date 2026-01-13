// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ProtocolAddresses
 * @notice Contract ID constants for registry
 */
library ProtocolAddresses {
    bytes32 public constant SAVINGS_VAULT = keccak256("SAVINGS_VAULT");
    bytes32 public constant TOKEN_VAULT = keccak256("TOKEN_VAULT");
    bytes32 public constant RECURRING_DEPOSIT = keccak256("RECURRING_DEPOSIT");
    bytes32 public constant TEMPLATE_REGISTRY = keccak256("TEMPLATE_REGISTRY");
    bytes32 public constant REFERRAL_SYSTEM = keccak256("REFERRAL_SYSTEM");
    bytes32 public constant YIELD_MANAGER = keccak256("YIELD_MANAGER");
    bytes32 public constant MULTISIG_VAULT = keccak256("MULTISIG_VAULT");
    bytes32 public constant NFT_RECEIPT = keccak256("NFT_RECEIPT");
    bytes32 public constant GOVERNOR = keccak256("GOVERNOR");
    bytes32 public constant TIMELOCK = keccak256("TIMELOCK");
    bytes32 public constant STAKING = keccak256("STAKING");
    bytes32 public constant PRICE_ORACLE = keccak256("PRICE_ORACLE");
}
