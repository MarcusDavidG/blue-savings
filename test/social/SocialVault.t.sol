// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/social/SocialVault.sol";

contract SocialVaultTest is Test {
    SocialVault public vault;
    address public creator;
    address public member1;
    address public member2;

    function setUp() public {
        vault = new SocialVault();
        creator = makeAddr("creator");
        member1 = makeAddr("member1");
        member2 = makeAddr("member2");
        vm.deal(creator, 10 ether);
        vm.deal(member1, 10 ether);
    }

    function test_CreateGroupVault() public {
        address[] memory members = new address[](1);
        members[0] = member1;

        vm.prank(creator);
        uint256 vaultId = vault.createGroupVault("Test Vault", 5 ether, 30 days, members);

        assertEq(vaultId, 0);
        assertTrue(vault.isMember(vaultId, creator));
        assertTrue(vault.isMember(vaultId, member1));
    }

    function test_Invite() public {
        address[] memory members = new address[](0);

        vm.prank(creator);
        uint256 vaultId = vault.createGroupVault("Test", 5 ether, 30 days, members);

        vm.prank(creator);
        vault.invite(vaultId, member2);

        assertTrue(vault.isInviteValid(vaultId, member2));
    }

    function test_AcceptInvite() public {
        address[] memory members = new address[](0);

        vm.prank(creator);
        uint256 vaultId = vault.createGroupVault("Test", 5 ether, 30 days, members);

        vm.prank(creator);
        vault.invite(vaultId, member2);

        vm.prank(member2);
        vault.acceptInvite(vaultId);

        assertTrue(vault.isMember(vaultId, member2));
    }
}
