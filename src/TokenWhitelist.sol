// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenWhitelist
 * @notice Manages approved ERC-20 tokens for the savings vault
 * @dev Owner-controlled whitelist for supported deposit tokens
 */
abstract contract TokenWhitelist {
    /// @notice Mapping of token address to whitelist status
    mapping(address => bool) public isTokenWhitelisted;

    /// @notice Array of all whitelisted token addresses
    address[] public whitelistedTokens;

    /// @notice Mapping to track index in whitelistedTokens array
    mapping(address => uint256) private _tokenIndex;

    /// @notice Emitted when a token is added to whitelist
    event TokenWhitelisted(address indexed token);

    /// @notice Emitted when a token is removed from whitelist
    event TokenDelisted(address indexed token);

    /// @notice Thrown when token is not whitelisted
    error TokenNotWhitelisted(address token);

    /// @notice Thrown when token is already whitelisted
    error TokenAlreadyWhitelisted(address token);

    /// @notice Thrown when token address is invalid
    error InvalidTokenAddress();

    /// @notice Modifier to check if token is whitelisted
    modifier onlyWhitelistedToken(address token) {
        if (!isTokenWhitelisted[token]) {
            revert TokenNotWhitelisted(token);
        }
        _;
    }

    /// @notice Internal function to add token to whitelist
    /// @param token The token address to whitelist
    function _whitelistToken(address token) internal {
        if (token == address(0)) revert InvalidTokenAddress();
        if (isTokenWhitelisted[token]) revert TokenAlreadyWhitelisted(token);

        isTokenWhitelisted[token] = true;
        _tokenIndex[token] = whitelistedTokens.length;
        whitelistedTokens.push(token);

        emit TokenWhitelisted(token);
    }

    /// @notice Internal function to remove token from whitelist
    /// @param token The token address to delist
    function _delistToken(address token) internal {
        if (!isTokenWhitelisted[token]) revert TokenNotWhitelisted(token);

        isTokenWhitelisted[token] = false;

        uint256 index = _tokenIndex[token];
        uint256 lastIndex = whitelistedTokens.length - 1;

        if (index != lastIndex) {
            address lastToken = whitelistedTokens[lastIndex];
            whitelistedTokens[index] = lastToken;
            _tokenIndex[lastToken] = index;
        }

        whitelistedTokens.pop();
        delete _tokenIndex[token];

        emit TokenDelisted(token);
    }

    /// @notice Get all whitelisted tokens
    /// @return Array of whitelisted token addresses
    function getWhitelistedTokens() external view returns (address[] memory) {
        return whitelistedTokens;
    }

    /// @notice Get count of whitelisted tokens
    /// @return Number of whitelisted tokens
    function getWhitelistedTokenCount() external view returns (uint256) {
        return whitelistedTokens.length;
    }
}
