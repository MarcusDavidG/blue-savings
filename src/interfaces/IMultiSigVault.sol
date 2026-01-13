// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../multisig/MultiSigTypes.sol";

/**
 * @title IMultiSigVault
 * @notice Interface for MultiSigVault
 */
interface IMultiSigVault {
    function createMultiSigVault(
        address[] calldata signers,
        uint256 threshold
    ) external returns (uint256 vaultId);

    function depositETH(uint256 vaultId) external payable;

    function depositToken(uint256 vaultId, address token, uint256 amount) external;

    function proposeTransaction(
        uint256 vaultId,
        address to,
        uint256 value,
        bytes calldata data
    ) external returns (uint256 txId);

    function approveTransaction(uint256 vaultId, uint256 txId) external;

    function executeTransaction(uint256 vaultId, uint256 txId) external;

    function cancelTransaction(uint256 vaultId, uint256 txId) external;

    function getConfig(uint256 vaultId) external view returns (MultiSigTypes.MultiSigConfig memory);

    function getTransaction(uint256 vaultId, uint256 txId) external view returns (MultiSigTypes.Transaction memory);

    function getTransactionCount(uint256 vaultId) external view returns (uint256);

    function hasApproved(uint256 vaultId, uint256 txId, address signer) external view returns (bool);
}
