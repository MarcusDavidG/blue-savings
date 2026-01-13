// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenFeeManager
 * @notice Manages protocol fees for token deposits
 * @dev Tracks accumulated fees per token type
 */
abstract contract TokenFeeManager {
    /// @notice Mapping: token => accumulated fees
    mapping(address => uint256) public tokenFeesCollected;

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
}
