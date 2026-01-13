// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/staking/StakingRewards.sol";
import "../../src/mocks/MockERC20.sol";

contract StakingRewardsTest is Test {
    StakingRewards public staking;
    MockERC20 public stakingToken;
    MockERC20 public rewardsToken;
    address public user1;

    function setUp() public {
        user1 = makeAddr("user1");

        stakingToken = new MockERC20("Stake", "STK", 18);
        rewardsToken = new MockERC20("Reward", "RWD", 18);
        staking = new StakingRewards(address(stakingToken), address(rewardsToken));

        stakingToken.mint(user1, 1000e18);
        rewardsToken.mint(address(staking), 10000e18);

        staking.setRewardRate(1e18); // 1 token per second
    }

    function test_Stake() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 100e18);
        staking.stake(100e18);
        vm.stopPrank();

        assertEq(staking.balanceOf(user1), 100e18);
        assertEq(staking.totalSupply(), 100e18);
    }

    function test_Withdraw() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 100e18);
        staking.stake(100e18);
        staking.withdraw(50e18);
        vm.stopPrank();

        assertEq(staking.balanceOf(user1), 50e18);
    }

    function test_EarnedRewards() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 100e18);
        staking.stake(100e18);
        vm.stopPrank();

        vm.warp(block.timestamp + 100);

        uint256 earned = staking.earned(user1);
        assertGt(earned, 0);
    }

    function test_ClaimReward() public {
        vm.startPrank(user1);
        stakingToken.approve(address(staking), 100e18);
        staking.stake(100e18);
        vm.stopPrank();

        vm.warp(block.timestamp + 100);

        uint256 balanceBefore = rewardsToken.balanceOf(user1);
        vm.prank(user1);
        staking.getReward();
        uint256 balanceAfter = rewardsToken.balanceOf(user1);

        assertGt(balanceAfter, balanceBefore);
    }
}
