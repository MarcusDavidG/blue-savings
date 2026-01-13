// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title WadRayMath
 * @notice Fixed point math with 18 and 27 decimal precision
 */
library WadRayMath {
    uint256 constant WAD = 1e18;
    uint256 constant HALF_WAD = 5e17;
    uint256 constant RAY = 1e27;
    uint256 constant HALF_RAY = 5e26;
    uint256 constant WAD_RAY_RATIO = 1e9;

    function wadMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b + HALF_WAD) / WAD;
    }

    function wadDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * WAD + b / 2) / b;
    }

    function rayMul(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * b + HALF_RAY) / RAY;
    }

    function rayDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a * RAY + b / 2) / b;
    }

    function rayToWad(uint256 a) internal pure returns (uint256) {
        return (a + WAD_RAY_RATIO / 2) / WAD_RAY_RATIO;
    }

    function wadToRay(uint256 a) internal pure returns (uint256) {
        return a * WAD_RAY_RATIO;
    }
}
