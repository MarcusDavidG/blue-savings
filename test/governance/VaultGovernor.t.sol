// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/governance/VaultGovernor.sol";

contract VaultGovernorTest is Test {
    VaultGovernor public governor;
    address public voter1;
    address public voter2;

    function setUp() public {
        governor = new VaultGovernor();
        voter1 = makeAddr("voter1");
        voter2 = makeAddr("voter2");

        governor.setVotingPower(voter1, 100e18);
        governor.setVotingPower(voter2, 50e18);
    }

    function test_CreateProposal() public {
        vm.prank(voter1);
        uint256 proposalId = governor.propose("Test proposal");

        assertEq(proposalId, 0);
        (,address proposer,,,,,,,) = governor.proposals(proposalId);
        assertEq(proposer, voter1);
    }

    function test_CastVote() public {
        vm.prank(voter1);
        uint256 proposalId = governor.propose("Test");

        vm.roll(block.number + 2);

        vm.prank(voter2);
        governor.castVote(proposalId, true);

        assertTrue(governor.hasVoted(proposalId, voter2));
    }

    function test_ProposalState() public {
        vm.prank(voter1);
        uint256 proposalId = governor.propose("Test");

        assertEq(uint256(governor.state(proposalId)), uint256(VaultGovernor.ProposalState.Pending));

        vm.roll(block.number + 2);
        assertEq(uint256(governor.state(proposalId)), uint256(VaultGovernor.ProposalState.Active));
    }

    function test_RevertDoubleVote() public {
        vm.prank(voter1);
        uint256 proposalId = governor.propose("Test");

        vm.roll(block.number + 2);

        vm.prank(voter1);
        governor.castVote(proposalId, true);

        vm.prank(voter1);
        vm.expectRevert(VaultGovernor.AlreadyVoted.selector);
        governor.castVote(proposalId, false);
    }
}
