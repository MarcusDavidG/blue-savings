// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ChainIds
 * @notice Chain ID constants for supported networks
 */
library ChainIds {
    uint256 public constant BASE_MAINNET = 8453;
    uint256 public constant BASE_SEPOLIA = 84532;
    uint256 public constant ETHEREUM_MAINNET = 1;
    uint256 public constant OPTIMISM = 10;
    uint256 public constant ARBITRUM = 42161;
    uint256 public constant POLYGON = 137;

    function isBase(uint256 chainId) internal pure returns (bool) {
        return chainId == BASE_MAINNET || chainId == BASE_SEPOLIA;
    }

    function isMainnet(uint256 chainId) internal pure returns (bool) {
        return chainId == BASE_MAINNET || 
               chainId == ETHEREUM_MAINNET ||
               chainId == OPTIMISM ||
               chainId == ARBITRUM ||
               chainId == POLYGON;
    }
}
