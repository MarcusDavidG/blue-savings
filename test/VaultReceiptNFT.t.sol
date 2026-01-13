// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/nft/VaultReceiptNFT.sol";

contract VaultReceiptNFTTest is Test {
    VaultReceiptNFT public nft;

    address public vault;
    address public user1;
    address public user2;

    function setUp() public {
        vault = makeAddr("vault");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        nft = new VaultReceiptNFT();
        nft.setSavingsVault(vault);
    }

    function test_Mint() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(
            user1,
            1, // vaultId
            address(0), // ETH
            1 ether,
            5 ether,
            block.timestamp + 30 days
        );

        assertEq(nft.ownerOf(tokenId), user1);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.totalSupply(), 1);
    }

    function test_Burn() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(user1, 1, address(0), 1 ether, 5 ether, 0);

        vm.prank(vault);
        nft.burn(tokenId);

        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.totalSupply(), 0);
    }

    function test_Transfer() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(user1, 1, address(0), 1 ether, 0, 0);

        vm.prank(user1);
        nft.transferFrom(user1, user2, tokenId);

        assertEq(nft.ownerOf(tokenId), user2);
        assertEq(nft.balanceOf(user1), 0);
        assertEq(nft.balanceOf(user2), 1);
    }

    function test_TokenURI() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(user1, 1, address(0), 1 ether, 5 ether, 0);

        string memory uri = nft.tokenURI(tokenId);
        assertTrue(bytes(uri).length > 0);
    }

    function test_VaultMetadata() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(
            user1,
            42,
            address(0x123),
            2 ether,
            10 ether,
            block.timestamp + 60 days
        );

        (
            uint256 vaultId,
            address token,
            uint256 initialDeposit,
            uint256 goalAmount,
            uint256 unlockTimestamp,
        ) = nft.vaultMetadata(tokenId);

        assertEq(vaultId, 42);
        assertEq(token, address(0x123));
        assertEq(initialDeposit, 2 ether);
        assertEq(goalAmount, 10 ether);
        assertEq(unlockTimestamp, block.timestamp + 60 days);
    }

    function test_RevertNonVaultMint() public {
        vm.prank(user1);
        vm.expectRevert(VaultReceiptNFT.Unauthorized.selector);
        nft.mint(user1, 1, address(0), 1 ether, 0, 0);
    }

    function test_RevertUnauthorizedTransfer() public {
        vm.prank(vault);
        uint256 tokenId = nft.mint(user1, 1, address(0), 1 ether, 0, 0);

        vm.prank(user2);
        vm.expectRevert(VaultReceiptNFT.NotOwnerOrApproved.selector);
        nft.transferFrom(user1, user2, tokenId);
    }
}
