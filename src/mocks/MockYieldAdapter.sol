// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IYieldAdapter.sol";

/**
 * @title MockYieldAdapter
 * @notice Mock yield adapter for testing
 */
contract MockYieldAdapter is IYieldAdapter {
    mapping(address => bool) public supported;
    mapping(address => uint256) public apys;
    mapping(address => uint256) public balances;

    function setSupported(address token, bool _supported) external {
        supported[token] = _supported;
    }

    function setAPY(address token, uint256 apy) external {
        apys[token] = apy;
    }

    function setBalance(address token, uint256 balance) external {
        balances[token] = balance;
    }

    function deposit(address, uint256 amount) external override returns (uint256) {
        return amount;
    }

    function withdraw(address, uint256 amount) external override returns (uint256) {
        return amount;
    }

    function getBalance(address token, address) external view override returns (uint256) {
        return balances[token];
    }

    function getAPY(address token) external view override returns (uint256) {
        return apys[token];
    }

    function isSupported(address token) external view override returns (bool) {
        return supported[token];
    }

    function protocolName() external pure override returns (string memory) {
        return "Mock Yield";
    }
}
