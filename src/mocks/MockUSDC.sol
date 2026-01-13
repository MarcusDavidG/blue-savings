// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

/**
 * @title MockUSDC
 * @notice Mock USDC token for testing
 * @dev 6 decimals like real USDC
 */
contract MockUSDC is MockERC20 {
    constructor() MockERC20("USD Coin", "USDC", 6) {}
}
