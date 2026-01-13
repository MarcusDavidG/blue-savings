// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/SavingsVault.sol";

contract FullFlowTest is Test {
    SavingsVault public vault;
    address public user;

    function setUp() public {
        vault = new SavingsVault();
        user = makeAddr("user");
        vm.deal(user, 100 ether);
    }

    function test_FullSavingsFlow() public {
        // Create vault
        vm.prank(user);
        uint256 vaultId = vault.createVault(5 ether, block.timestamp + 30 days, "My Savings");

        // Make deposits
        vm.startPrank(user);
        vault.deposit{value: 2 ether}(vaultId);
        vault.deposit{value: 2 ether}(vaultId);
        vault.deposit{value: 2 ether}(vaultId);
        vm.stopPrank();

        // Check balance (minus fees)
        uint256 balance = vault.getVaultBalance(vaultId);
        assertGt(balance, 5.9 ether);

        // Fast forward past unlock
        vm.warp(block.timestamp + 31 days);

        // Withdraw
        uint256 userBalanceBefore = user.balance;
        vm.prank(user);
        vault.withdraw(vaultId);
        uint256 userBalanceAfter = user.balance;

        assertGt(userBalanceAfter, userBalanceBefore);
    }

    function test_EmergencyWithdrawFlow() public {
        vm.prank(user);
        uint256 vaultId = vault.createVault(0, block.timestamp + 365 days, "Locked");

        vm.prank(user);
        vault.deposit{value: 5 ether}(vaultId);

        // Emergency withdraw before unlock
        uint256 balanceBefore = user.balance;
        vm.prank(user);
        vault.emergencyWithdraw(vaultId);
        uint256 balanceAfter = user.balance;

        assertGt(balanceAfter, balanceBefore);
    }
}
