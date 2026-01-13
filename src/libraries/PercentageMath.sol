// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PercentageMath
 * @notice Percentage calculations with basis points
 */
library PercentageMath {
    uint256 constant PERCENTAGE_FACTOR = 1e4; // 100.00%
    uint256 constant HALF_PERCENTAGE = 5e3;   // 50.00%

    function percentMul(uint256 value, uint256 percentage) internal pure returns (uint256) {
        if (value == 0 || percentage == 0) return 0;
        return (value * percentage + HALF_PERCENTAGE) / PERCENTAGE_FACTOR;
    }

    function percentDiv(uint256 value, uint256 percentage) internal pure returns (uint256) {
        if (value == 0 || percentage == 0) return 0;
        return (value * PERCENTAGE_FACTOR + percentage / 2) / percentage;
    }
}
