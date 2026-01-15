// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IYieldAdapter.sol";
import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title BaseYieldAdapter
 * @notice Base contract for yield protocol adapters
 * @dev Common functionality for all yield adapters
 */
abstract contract BaseYieldAdapter is IYieldAdapter {
    using SafeERC20 for IERC20;

    /// @notice Owner of the adapter
    address public owner;

    /// @notice Vault contract that uses this adapter
    address public vault;

    /// @notice Mapping of token to supported status
    mapping(address => bool) public supportedTokens;

    // Events
    event TokenSupported(address indexed token, bool supported);
    event Deposited(address indexed token, uint256 amount, uint256 shares);
    event Withdrawn(address indexed token, uint256 amount);
    event YieldHarvested(address indexed token, uint256 amount);
    event RewardsCompounded(address indexed token, uint256 amount);

    // Errors
    error Unauthorized();
    error UnsupportedToken(address token);
    error ZeroAmount();
    error ZeroAddress();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyVault() {
        if (msg.sender != vault) revert Unauthorized();
        _;
    }

    modifier supportedToken(address token) {
        if (!supportedTokens[token]) revert UnsupportedToken(token);
        _;
    }

    constructor(address _vault) {
        if (_vault == address(0)) revert ZeroAddress();
        owner = msg.sender;
        vault = _vault;
    }

    /// @notice Set token support status
    function setTokenSupport(address token, bool supported) external onlyOwner {
        supportedTokens[token] = supported;
        emit TokenSupported(token, supported);
    }

    /// @notice Check if token is supported
    function isSupported(address token) external view override returns (bool) {
        return supportedTokens[token];
    }

    /// @notice Internal deposit implementation
    function _deposit(address token, uint256 amount) internal virtual returns (uint256);

    /// @notice Internal withdraw implementation
    function _withdraw(address token, uint256 amount) internal virtual returns (uint256);

    /// @notice Internal balance check
    function _getBalance(address token, address account) internal view virtual returns (uint256);

    /// @notice Rescue stuck tokens (emergency)
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner, amount);
    }

    /// @notice Harvest yield from protocol
    /// @param token Token to harvest yield for
    /// @return harvested Amount of yield harvested
    function harvest(address token) external virtual onlyVault returns (uint256 harvested) {
        harvested = _harvest(token);
        if (harvested > 0) {
            emit YieldHarvested(token, harvested);
        }
    }

    /// @notice Internal harvest implementation (override in adapters)
    function _harvest(address) internal virtual returns (uint256) {
        return 0;
    }

    /// @notice Get pending yield that can be harvested
    function getPendingYield(address token) external view virtual returns (uint256) {
        return _getPendingYield(token);
    }

    /// @notice Internal pending yield check
    function _getPendingYield(address) internal view virtual returns (uint256) {
        return 0;
    }
}
