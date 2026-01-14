// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BaseTokenAddresses
 * @notice Token addresses on Base mainnet
 * @dev Constant addresses for commonly used tokens on Base
 */
library BaseTokenAddresses {
    /// @notice USDC on Base (6 decimals)
    address public constant USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;

    /// @notice DAI on Base (18 decimals)
    address public constant DAI = 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb;

    /// @notice WETH on Base (18 decimals)
    address public constant WETH = 0x4200000000000000000000000000000000000006;

    /// @notice USDbC (Bridged USDC) on Base (6 decimals)
    address public constant USDbC = 0xd9aAEc86B65D86f6A7B5B1b0c42FFA531710b6CA;

    /// @notice cbETH on Base (18 decimals)
    address public constant cbETH = 0x2Ae3F1Ec7F1F5012CFEab0185bfc7aa3cf0DEc22;

    /// @notice AERO token on Base (18 decimals)
    address public constant AERO = 0x940181a94A35A4569E4529A3CDfB74e38FD98631;

    /// @notice Check if token is a known stablecoin
    /// @param token The address of the token to check
    /// @return bool True if the token is a stablecoin, false otherwise
    function isStablecoin(address token) internal pure returns (bool) {
        return token == USDC || token == DAI || token == USDbC;
    }

    /// @notice Check if token is wrapped ETH derivative
    /// @param token The address of the token to check
    /// @return bool True if the token is a WETH derivative, false otherwise
    function isWethDerivative(address token) internal pure returns (bool) {
        return token == WETH || token == cbETH;
    }

    /// @notice Get expected decimals for known tokens
    /// @param token The address of the token to check
    /// @return uint8 The number of decimals for the token
    function getDecimals(address token) internal pure returns (uint8) {
        if (token == USDC || token == USDbC) return 6;
        return 18; // Default for most tokens
    }
}
