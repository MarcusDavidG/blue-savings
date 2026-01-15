// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenFeeManager
 * @notice Manages protocol fees for token deposits
 * @dev Tracks accumulated fees per token type and supports token-specific fee tiers
 */
abstract contract TokenFeeManager {
    /// @notice Mapping: token => accumulated fees
    mapping(address => uint256) public tokenFeesCollected;

    /// @notice Mapping: token => custom fee in basis points (0 = use default)
    mapping(address => uint256) public tokenFeeTiers;

    /// @notice Default fee when no token-specific tier is set
    uint256 public defaultFeeBps = 50; // 0.5%

    /// @notice Emitted when token fees are collected
    event TokenFeeCollected(address indexed token, address indexed collector, uint256 amount);

    /// @notice Get accumulated fees for a token
    /// @param token The token address
    /// @return Accumulated fee amount
    function getTokenFees(address token) external view returns (uint256) {
        return tokenFeesCollected[token];
    }

    /// @notice Internal: Add fees for a token
    function _addTokenFee(address token, uint256 amount) internal {
        unchecked {
            tokenFeesCollected[token] += amount;
        }
    }

    /// @notice Internal: Reset fees for a token after collection
    function _resetTokenFees(address token) internal returns (uint256 amount) {
        amount = tokenFeesCollected[token];
        tokenFeesCollected[token] = 0;
    }

    /// @notice Get the fee tier for a specific token
    /// @param token The token address
    /// @return Fee in basis points (returns default if not set)
    function getTokenFeeBps(address token) public view returns (uint256) {
        uint256 customFee = tokenFeeTiers[token];
        return customFee > 0 ? customFee : defaultFeeBps;
    }

    /// @notice Internal: Set a token-specific fee tier
    /// @param token The token address
    /// @param feeBps Fee in basis points (0 to use default)
    function _setTokenFeeTier(address token, uint256 feeBps) internal {
        tokenFeeTiers[token] = feeBps;
    }

    /// @notice Internal: Set the default fee
    /// @param feeBps Default fee in basis points
    function _setDefaultFeeBps(uint256 feeBps) internal {
        defaultFeeBps = feeBps;
    }
}
