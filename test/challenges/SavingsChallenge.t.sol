// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/challenges/SavingsChallenge.sol";

contract SavingsChallengeTest is Test {
    SavingsChallenge public challenge;
    address public user1;
    address public user2;

    function setUp() public {
        challenge = new SavingsChallenge();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }

    function test_CreateChallenge() public {
        uint256 id = challenge.createChallenge{value: 1 ether}("30 Day Challenge", 1 ether, 30 days);
        assertEq(id, 0);

        (string memory name,,,,,,) = challenge.challenges(id);
        assertEq(name, "30 Day Challenge");
    }

    function test_JoinChallenge() public {
        uint256 id = challenge.createChallenge{value: 1 ether}("Test", 1 ether, 30 days);

        vm.prank(user1);
        challenge.joinChallenge{value: 0.5 ether}(id);

        (uint256 deposited,,,) = challenge.participants(id, user1);
        assertEq(deposited, 0.5 ether);
    }

    function test_CompleteChallenge() public {
        uint256 id = challenge.createChallenge{value: 1 ether}("Test", 1 ether, 30 days);

        vm.prank(user1);
        challenge.joinChallenge{value: 1 ether}(id);

        (,, bool completed,) = challenge.participants(id, user1);
        assertTrue(completed);
    }
}
