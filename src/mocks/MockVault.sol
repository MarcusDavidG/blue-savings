// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MockVault
 * @notice Mock vault for integration testing
 */
contract MockVault {
    mapping(uint256 => uint256) public balances;
    uint256 public vaultCounter;

    event VaultCreated(uint256 indexed vaultId);
    event Deposited(uint256 indexed vaultId, uint256 amount);
    event Withdrawn(uint256 indexed vaultId, uint256 amount);

    function createVault() external returns (uint256) {
        uint256 vaultId = vaultCounter++;
        emit VaultCreated(vaultId);
        return vaultId;
    }

    function deposit(uint256 vaultId) external payable {
        balances[vaultId] += msg.value;
        emit Deposited(vaultId, msg.value);
    }

    function withdraw(uint256 vaultId) external {
        uint256 amount = balances[vaultId];
        balances[vaultId] = 0;
        payable(msg.sender).transfer(amount);
        emit Withdrawn(vaultId, amount);
    }

    function getBalance(uint256 vaultId) external view returns (uint256) {
        return balances[vaultId];
    }
}
