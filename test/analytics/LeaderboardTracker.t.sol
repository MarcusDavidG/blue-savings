// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/analytics/LeaderboardTracker.sol";

contract LeaderboardTrackerTest is Test {
    LeaderboardTracker public tracker;
    address public user1;
    address public user2;

    function setUp() public {
        tracker = new LeaderboardTracker();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function test_UpdateUser() public {
        tracker.updateUser(user1, 100e18, 5, 30 days);

        uint256 rank = tracker.getRank(user1);
        assertEq(rank, 1);
    }

    function test_Leaderboard() public {
        tracker.updateUser(user1, 100e18, 5, 30 days);
        tracker.updateUser(user2, 200e18, 3, 60 days);

        LeaderboardTracker.Entry[] memory top = tracker.getTopN(2);
        assertEq(top[0].user, user2);
        assertEq(top[1].user, user1);
    }

    function test_Achievement() public {
        tracker.updateUser(user1, 100e18, 1, 30 days);
        tracker.checkAchievements(user1, 1, 100e18);

        assertTrue(tracker.achievements(user1, LeaderboardTracker.Achievement.FirstDeposit));
    }
}
