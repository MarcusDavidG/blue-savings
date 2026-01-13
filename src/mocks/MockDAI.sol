// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

/**
 * @title MockDAI
 * @notice Mock DAI token for testing
 * @dev 18 decimals like real DAI
 */
contract MockDAI is MockERC20 {
    constructor() MockERC20("Dai Stablecoin", "DAI", 18) {}
}
