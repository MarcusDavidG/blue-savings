// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultWithdrawTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;

    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);

        vault.whitelistToken(address(usdc));
        usdc.mint(user1, 10000e6);
    }

    function test_WithdrawFromFlexibleVault() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Flexible");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        uint256 balanceBefore = usdc.balanceOf(user1);
        vault.withdrawToken(vaultId, address(usdc));
        uint256 balanceAfter = usdc.balanceOf(user1);
        vm.stopPrank();

        assertGt(balanceAfter, balanceBefore);
        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
    }

    function test_WithdrawFromTimeLocked_AfterUnlock() public {
        uint256 unlockTime = block.timestamp + 30 days;

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, unlockTime, "Time-locked");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        // Fast forward past unlock
        vm.warp(unlockTime + 1);

        vault.withdrawToken(vaultId, address(usdc));
        vm.stopPrank();

        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
    }

    function test_WithdrawFromTimeLocked_BeforeUnlockReverts() public {
        uint256 unlockTime = block.timestamp + 30 days;

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, unlockTime, "Time-locked");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        vm.expectRevert(TokenSavingsVault.VaultLocked.selector);
        vault.withdrawToken(vaultId, address(usdc));
        vm.stopPrank();
    }

    function test_WithdrawFromGoalBased_GoalReached() public {
        uint256 goalAmount = 500e6;

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(usdc), goalAmount, 0, "Goal-based");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        vault.withdrawToken(vaultId, address(usdc));
        vm.stopPrank();

        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
    }

    function test_WithdrawFromGoalBased_GoalNotReachedReverts() public {
        uint256 goalAmount = 2000e6; // More than we'll deposit

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(usdc), goalAmount, 0, "Goal-based");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        vm.expectRevert(TokenSavingsVault.GoalNotReached.selector);
        vault.withdrawToken(vaultId, address(usdc));
        vm.stopPrank();
    }

    function test_NonOwnerCannotWithdraw() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vm.stopPrank();

        vm.prank(user2);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.withdrawToken(vaultId, address(usdc));
    }

    function test_WithdrawZeroBalanceReverts() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.NoTokenBalance.selector);
        vault.withdrawToken(vaultId, address(usdc));
    }

    function test_WithdrawEmitsEvent() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        uint256 depositAmount = 1000e6;
        uint256 expectedDeposit = depositAmount - (depositAmount * 50 / 10000);

        vm.startPrank(user1);
        usdc.approve(address(vault), depositAmount);
        vault.depositToken(vaultId, address(usdc), depositAmount);

        vm.expectEmit(true, true, true, true);
        emit TokenSavingsVault.TokenWithdrawn(vaultId, user1, address(usdc), expectedDeposit);

        vault.withdrawToken(vaultId, address(usdc));
        vm.stopPrank();
    }
}
