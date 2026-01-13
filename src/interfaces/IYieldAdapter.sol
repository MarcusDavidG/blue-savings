// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IYieldAdapter
 * @notice Interface for yield protocol adapters
 * @dev Standard interface for Aave, Compound integrations
 */
interface IYieldAdapter {
    /// @notice Deposit tokens into yield protocol
    /// @param token Token to deposit
    /// @param amount Amount to deposit
    /// @return shares Amount of yield-bearing tokens received
    function deposit(address token, uint256 amount) external returns (uint256 shares);

    /// @notice Withdraw tokens from yield protocol
    /// @param token Token to withdraw
    /// @param amount Amount to withdraw
    /// @return withdrawn Actual amount withdrawn
    function withdraw(address token, uint256 amount) external returns (uint256 withdrawn);

    /// @notice Get current balance including yield
    /// @param token Token to check
    /// @param account Account to check
    /// @return balance Current balance with accrued yield
    function getBalance(address token, address account) external view returns (uint256 balance);

    /// @notice Get current APY for token
    /// @param token Token to check
    /// @return apy Annual percentage yield in basis points
    function getAPY(address token) external view returns (uint256 apy);

    /// @notice Check if token is supported
    /// @param token Token to check
    /// @return supported True if token can earn yield
    function isSupported(address token) external view returns (bool supported);

    /// @notice Get protocol name
    /// @return name Protocol identifier string
    function protocolName() external view returns (string memory name);
}
