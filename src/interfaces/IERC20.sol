// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IERC20
 * @notice Standard ERC-20 token interface
 * @dev Interface for ERC-20 tokens as defined in EIP-20
 */
interface IERC20 {
    /// @notice Returns the total token supply
    function totalSupply() external view returns (uint256);

    /// @notice Returns the token balance of an account
    /// @param account The address to query
    function balanceOf(address account) external view returns (uint256);

    /// @notice Transfers tokens to a recipient
    /// @param to The recipient address
    /// @param amount The amount to transfer
    function transfer(address to, uint256 amount) external returns (bool);

    /// @notice Returns the remaining allowance for a spender
    /// @param owner The token owner
    /// @param spender The spender address
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice Approves a spender to spend tokens
    /// @param spender The spender address
    /// @param amount The amount to approve
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice Transfers tokens from one address to another
    /// @param from The sender address
    /// @param to The recipient address
    /// @param amount The amount to transfer
    function transferFrom(address from, address to, uint256 amount) external returns (bool);

    /// @notice Emitted when tokens are transferred
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice Emitted when allowance is set
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
