// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/utils/Math.sol";

contract MathTest is Test {
    function test_Max() public pure {
        assertEq(Math.max(5, 3), 5);
        assertEq(Math.max(3, 5), 5);
        assertEq(Math.max(5, 5), 5);
    }

    function test_Min() public pure {
        assertEq(Math.min(5, 3), 3);
        assertEq(Math.min(3, 5), 3);
        assertEq(Math.min(5, 5), 5);
    }

    function test_Average() public pure {
        assertEq(Math.average(4, 6), 5);
        assertEq(Math.average(5, 5), 5);
        assertEq(Math.average(0, 10), 5);
    }

    function test_CeilDiv() public pure {
        assertEq(Math.ceilDiv(10, 3), 4);
        assertEq(Math.ceilDiv(9, 3), 3);
        assertEq(Math.ceilDiv(0, 5), 0);
    }

    function test_Sqrt() public pure {
        assertEq(Math.sqrt(0), 0);
        assertEq(Math.sqrt(1), 1);
        assertEq(Math.sqrt(4), 2);
        assertEq(Math.sqrt(9), 3);
        assertEq(Math.sqrt(16), 4);
        assertEq(Math.sqrt(100), 10);
    }

    function test_Log2() public pure {
        assertEq(Math.log2(1), 0);
        assertEq(Math.log2(2), 1);
        assertEq(Math.log2(4), 2);
        assertEq(Math.log2(8), 3);
        assertEq(Math.log2(256), 8);
    }
}
