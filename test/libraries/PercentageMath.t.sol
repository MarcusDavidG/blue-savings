// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/libraries/PercentageMath.sol";

contract PercentageMathTest is Test {
    using PercentageMath for uint256;

    function test_PercentMul() public pure {
        assertEq(uint256(1000).percentMul(5000), 500); // 50%
        assertEq(uint256(1000).percentMul(10000), 1000); // 100%
        assertEq(uint256(1000).percentMul(2500), 250); // 25%
    }

    function test_PercentDiv() public pure {
        assertEq(uint256(500).percentDiv(5000), 1000); // 500 is 50% of 1000
    }

    function test_ZeroValues() public pure {
        assertEq(uint256(0).percentMul(5000), 0);
        assertEq(uint256(1000).percentMul(0), 0);
    }
}
