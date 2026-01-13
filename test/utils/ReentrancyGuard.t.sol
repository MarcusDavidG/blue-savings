// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/utils/ReentrancyGuard.sol";

contract ReentrancyTest is ReentrancyGuard {
    uint256 public counter;

    function increment() external nonReentrant {
        counter++;
    }

    function reentrantCall() external nonReentrant {
        this.increment();
    }
}

contract ReentrancyGuardTest is Test {
    ReentrancyTest public target;

    function setUp() public {
        target = new ReentrancyTest();
    }

    function test_NonReentrantAllowsSingleCall() public {
        target.increment();
        assertEq(target.counter(), 1);
    }

    function test_NonReentrantBlocksReentry() public {
        vm.expectRevert(ReentrancyGuard.ReentrancyGuardReentrantCall.selector);
        target.reentrantCall();
    }
}
