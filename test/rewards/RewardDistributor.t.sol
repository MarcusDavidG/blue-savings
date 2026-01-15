// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/rewards/RewardDistributor.sol";
import "../../src/mocks/MockERC20.sol";

contract RewardDistributorTest is Test {
    RewardDistributor public distributor;
    MockERC20 public rewardToken;
    address public user1;

    function setUp() public {
        rewardToken = new MockERC20("Reward", "RWD", 18);
        distributor = new RewardDistributor(address(rewardToken));
        user1 = makeAddr("user1");

        rewardToken.mint(address(this), 1000e18);
        rewardToken.approve(address(distributor), 1000e18);
    }

    function test_StartEpoch() public {
        distributor.startEpoch(100e18);

        assertEq(distributor.currentEpoch(), 1);
        (uint256 rewards,,,) = distributor.epochs(1);
        assertEq(rewards, 100e18);
    }

    function test_RecordShares() public {
        distributor.startEpoch(100e18);
        distributor.recordShares(user1, 50e18);

        assertEq(distributor.userShares(1, user1), 50e18);
    }

    function test_ClaimableEpochs() public {
        distributor.startEpoch(100e18);
        distributor.recordShares(user1, 50e18);

        vm.warp(block.timestamp + 8 days);

        uint256[] memory claimable = distributor.getClaimableEpochs(user1);
        assertEq(claimable.length, 1);
        assertEq(claimable[0], 1);
    }
}
