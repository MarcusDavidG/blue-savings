// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultSnapshot
 * @notice Snapshot vault state at specific blocks
 */
contract VaultSnapshot {
    struct Snapshot {
        uint256 blockNumber;
        uint256 timestamp;
        uint256 totalVaults;
        uint256 totalDeposits;
        uint256 totalUsers;
    }

    Snapshot[] public snapshots;
    mapping(uint256 => mapping(address => uint256)) public balanceAt;
    address public owner;

    event SnapshotTaken(uint256 indexed snapshotId, uint256 blockNumber);

    constructor() {
        owner = msg.sender;
    }

    function takeSnapshot(uint256 totalVaults, uint256 totalDeposits, uint256 totalUsers) external {
        require(msg.sender == owner, "Not owner");

        snapshots.push(Snapshot({
            blockNumber: block.number,
            timestamp: block.timestamp,
            totalVaults: totalVaults,
            totalDeposits: totalDeposits,
            totalUsers: totalUsers
        }));

        emit SnapshotTaken(snapshots.length - 1, block.number);
    }

    function recordBalance(uint256 snapshotId, address user, uint256 balance) external {
        require(msg.sender == owner, "Not owner");
        balanceAt[snapshotId][user] = balance;
    }

    function getSnapshot(uint256 snapshotId) external view returns (Snapshot memory) {
        return snapshots[snapshotId];
    }

    function getSnapshotCount() external view returns (uint256) {
        return snapshots.length;
    }

    function getBalanceAt(uint256 snapshotId, address user) external view returns (uint256) {
        return balanceAt[snapshotId][user];
    }
}
