// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MultiSigTypes.sol";
import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title MultiSigVault
 * @notice Savings vault with multi-signature withdrawal requirement
 * @dev Requires threshold approvals before withdrawal execution
 */
contract MultiSigVault is MultiSigTypes {
    using SafeERC20 for IERC20;

    /// @notice Vault ID counter
    uint256 public vaultCounter;

    /// @notice Mapping of vault ID to config
    mapping(uint256 => MultiSigConfig) public configs;

    /// @notice Mapping of vault ID to ETH balance
    mapping(uint256 => uint256) public ethBalances;

    /// @notice Mapping of vault ID to token balances
    mapping(uint256 => mapping(address => uint256)) public tokenBalances;

    /// @notice Mapping of vault ID to transactions
    mapping(uint256 => Transaction[]) public transactions;

    /// @notice Mapping of vault ID to tx ID to signer to approval
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public approvals;

    /// @notice Mapping of vault ID to signer to isSigner
    mapping(uint256 => mapping(address => bool)) public isSigner;

    // Events
    event MultiSigVaultCreated(uint256 indexed vaultId, address[] signers, uint256 threshold);
    event Deposited(uint256 indexed vaultId, address indexed token, uint256 amount);
    event TransactionProposed(uint256 indexed vaultId, uint256 indexed txId, address proposer);
    event TransactionApproved(uint256 indexed vaultId, uint256 indexed txId, address signer);
    event TransactionExecuted(uint256 indexed vaultId, uint256 indexed txId);
    event TransactionCancelled(uint256 indexed vaultId, uint256 indexed txId);
    event SignerAdded(uint256 indexed vaultId, address signer);
    event SignerRemoved(uint256 indexed vaultId, address signer);
    event ThresholdUpdated(uint256 indexed vaultId, uint256 newThreshold);

    // Errors
    error InvalidThreshold();
    error NotSigner();
    error AlreadyApproved();
    error InsufficientApprovals();
    error TransactionNotPending();
    error InvalidSignersCount();
    error SignerAlreadyExists();
    error SignerNotFound();
    error ExecutionFailed();

    modifier onlySigner(uint256 vaultId) {
        if (!isSigner[vaultId][msg.sender]) revert NotSigner();
        _;
    }

    /// @notice Create a multi-sig vault
    function createMultiSigVault(
        address[] calldata signers,
        uint256 threshold
    ) external returns (uint256 vaultId) {
        if (signers.length < 2) revert InvalidSignersCount();
        if (threshold == 0 || threshold > signers.length) revert InvalidThreshold();

        vaultId = vaultCounter++;

        configs[vaultId] = MultiSigConfig({
            signers: signers,
            threshold: threshold,
            txCount: 0,
            isActive: true
        });

        for (uint256 i = 0; i < signers.length; i++) {
            isSigner[vaultId][signers[i]] = true;
        }

        emit MultiSigVaultCreated(vaultId, signers, threshold);
    }

    /// @notice Deposit ETH into vault
    function depositETH(uint256 vaultId) external payable {
        ethBalances[vaultId] += msg.value;
        emit Deposited(vaultId, address(0), msg.value);
    }

    /// @notice Deposit tokens into vault
    function depositToken(uint256 vaultId, address token, uint256 amount) external {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        tokenBalances[vaultId][token] += amount;
        emit Deposited(vaultId, token, amount);
    }

    /// @notice Propose a withdrawal transaction
    function proposeTransaction(
        uint256 vaultId,
        address to,
        uint256 value,
        bytes calldata data
    ) external onlySigner(vaultId) returns (uint256 txId) {
        txId = transactions[vaultId].length;

        transactions[vaultId].push(Transaction({
            vaultId: vaultId,
            to: to,
            value: value,
            data: data,
            approvalCount: 1, // Proposer auto-approves
            status: TxStatus.Pending,
            createdAt: block.timestamp,
            executedAt: 0
        }));

        approvals[vaultId][txId][msg.sender] = true;
        configs[vaultId].txCount++;

        emit TransactionProposed(vaultId, txId, msg.sender);
        emit TransactionApproved(vaultId, txId, msg.sender);
    }

    /// @notice Approve a pending transaction
    function approveTransaction(uint256 vaultId, uint256 txId) external onlySigner(vaultId) {
        if (approvals[vaultId][txId][msg.sender]) revert AlreadyApproved();
        if (transactions[vaultId][txId].status != TxStatus.Pending) revert TransactionNotPending();

        approvals[vaultId][txId][msg.sender] = true;
        transactions[vaultId][txId].approvalCount++;

        emit TransactionApproved(vaultId, txId, msg.sender);
    }

    /// @notice Execute a fully approved transaction
    function executeTransaction(uint256 vaultId, uint256 txId) external onlySigner(vaultId) {
        Transaction storage txn = transactions[vaultId][txId];

        if (txn.status != TxStatus.Pending) revert TransactionNotPending();
        if (txn.approvalCount < configs[vaultId].threshold) revert InsufficientApprovals();

        txn.status = TxStatus.Executed;
        txn.executedAt = block.timestamp;

        if (txn.value > 0) {
            ethBalances[vaultId] -= txn.value;
        }

        (bool success,) = txn.to.call{value: txn.value}(txn.data);
        if (!success) revert ExecutionFailed();

        emit TransactionExecuted(vaultId, txId);
    }

    /// @notice Cancel a pending transaction
    function cancelTransaction(uint256 vaultId, uint256 txId) external onlySigner(vaultId) {
        if (transactions[vaultId][txId].status != TxStatus.Pending) revert TransactionNotPending();

        transactions[vaultId][txId].status = TxStatus.Cancelled;
        emit TransactionCancelled(vaultId, txId);
    }

    /// @notice Get vault configuration
    function getConfig(uint256 vaultId) external view returns (MultiSigConfig memory) {
        return configs[vaultId];
    }

    /// @notice Get transaction details
    function getTransaction(uint256 vaultId, uint256 txId) external view returns (Transaction memory) {
        return transactions[vaultId][txId];
    }

    /// @notice Get transaction count for vault
    function getTransactionCount(uint256 vaultId) external view returns (uint256) {
        return transactions[vaultId].length;
    }

    /// @notice Check if signer approved transaction
    function hasApproved(uint256 vaultId, uint256 txId, address signer) external view returns (bool) {
        return approvals[vaultId][txId][signer];
    }
}
