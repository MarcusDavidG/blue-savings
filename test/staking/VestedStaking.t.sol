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
        staking = new VestedStaking(address(token));
        user1 = makeAddr("user1");

        token.mint(user1, 100e18);
        vm.prank(user1);
        token.approve(address(staking), 100e18);
    }

    function test_Stake() public {
        vm.prank(user1);
        staking.stake(50e18, 30 days);

        assertEq(staking.getStakeCount(user1), 1);
    }

    function test_UnstakeBeforeVesting() public {
        vm.prank(user1);
        staking.stake(50e18, 30 days);

        vm.prank(user1);
        vm.expectRevert();
        staking.claim(0);
    }

    function test_ClaimAfterVesting() public {
        vm.prank(user1);
        staking.stake(50e18, 30 days);

        vm.warp(block.timestamp + 31 days);

        vm.prank(user1);
        staking.claim(0);
    }
}
