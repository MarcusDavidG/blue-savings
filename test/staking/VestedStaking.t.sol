// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/staking/VestedStaking.sol";
import "../../src/mocks/MockERC20.sol";

contract VestedStakingTest is Test {
    VestedStaking public staking;
    MockERC20 public token;
    address public user1;

    function setUp() public {
        token = new MockERC20("Token", "TKN", 18);
        staking = new VestedStaking(address(token), 30 days);
        user1 = makeAddr("user1");

        token.mint(user1, 100e18);
        vm.prank(user1);
        token.approve(address(staking), 100e18);
    }

    function test_Stake() public {
        vm.prank(user1);
        staking.stake(50e18);

        assertEq(staking.balanceOf(user1), 50e18);
    }

    function test_UnstakeBeforeVesting() public {
        vm.prank(user1);
        staking.stake(50e18);

        vm.prank(user1);
        vm.expectRevert("Still vesting");
        staking.unstake(50e18);
    }

    function test_UnstakeAfterVesting() public {
        vm.prank(user1);
        staking.stake(50e18);

        vm.warp(block.timestamp + 31 days);

        vm.prank(user1);
        staking.unstake(50e18);

        assertEq(staking.balanceOf(user1), 0);
    }
}
