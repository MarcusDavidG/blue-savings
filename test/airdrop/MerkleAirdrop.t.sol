// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/airdrop/MerkleAirdrop.sol";
import "../../src/mocks/MockERC20.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop public airdrop;
    MockERC20 public token;

    bytes32 public root;
    address public user1;
    uint256 public amount1 = 100e18;

    function setUp() public {
        user1 = makeAddr("user1");
        token = new MockERC20("Test", "TST", 18);

        // Simple merkle root for testing
        bytes32 leaf = keccak256(abi.encodePacked(uint256(0), user1, amount1));
        root = leaf; // Single leaf tree

        airdrop = new MerkleAirdrop(address(token), root);
        token.mint(address(airdrop), 1000e18);
    }

    function test_Claim() public {
        bytes32[] memory proof = new bytes32[](0);
        
        airdrop.claim(0, user1, amount1, proof);
        
        assertEq(token.balanceOf(user1), amount1);
        assertTrue(airdrop.isClaimed(0));
    }

    function test_RevertDoubleClaim() public {
        bytes32[] memory proof = new bytes32[](0);
        
        airdrop.claim(0, user1, amount1, proof);
        
        vm.expectRevert(MerkleAirdrop.AlreadyClaimed.selector);
        airdrop.claim(0, user1, amount1, proof);
    }
}
