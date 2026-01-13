// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Timelock
 * @notice Time-delayed execution for governance actions
 */
contract Timelock {
    uint256 public constant MINIMUM_DELAY = 1 days;
    uint256 public constant MAXIMUM_DELAY = 30 days;

    address public admin;
    uint256 public delay;

    mapping(bytes32 => bool) public queuedTransactions;

    event NewDelay(uint256 delay);
    event QueueTransaction(bytes32 indexed txHash, address target, uint256 value, bytes data, uint256 eta);
    event ExecuteTransaction(bytes32 indexed txHash, address target, uint256 value, bytes data, uint256 eta);
    event CancelTransaction(bytes32 indexed txHash, address target, uint256 value, bytes data, uint256 eta);

    error Unauthorized();
    error DelayNotSatisfied();
    error TransactionNotQueued();
    error TransactionStale();
    error ExecutionFailed();

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized();
        _;
    }

    constructor(uint256 delay_) {
        admin = msg.sender;
        delay = delay_;
    }

    function setDelay(uint256 delay_) external onlyAdmin {
        require(delay_ >= MINIMUM_DELAY && delay_ <= MAXIMUM_DELAY, "Invalid delay");
        delay = delay_;
        emit NewDelay(delay_);
    }

    function queueTransaction(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 eta
    ) external onlyAdmin returns (bytes32) {
        if (eta < block.timestamp + delay) revert DelayNotSatisfied();

        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        queuedTransactions[txHash] = true;

        emit QueueTransaction(txHash, target, value, data, eta);
        return txHash;
    }

    function executeTransaction(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 eta
    ) external payable onlyAdmin returns (bytes memory) {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));

        if (!queuedTransactions[txHash]) revert TransactionNotQueued();
        if (block.timestamp < eta) revert DelayNotSatisfied();
        if (block.timestamp > eta + 14 days) revert TransactionStale();

        queuedTransactions[txHash] = false;

        (bool success, bytes memory returnData) = target.call{value: value}(data);
        if (!success) revert ExecutionFailed();

        emit ExecuteTransaction(txHash, target, value, data, eta);
        return returnData;
    }

    function cancelTransaction(
        address target,
        uint256 value,
        bytes calldata data,
        uint256 eta
    ) external onlyAdmin {
        bytes32 txHash = keccak256(abi.encode(target, value, data, eta));
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, data, eta);
    }

    receive() external payable {}
}
