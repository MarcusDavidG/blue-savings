// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultEmergencyTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;

    address public user1;
    address public user2;

    function setUp() public {
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);

        vault.whitelistToken(address(usdc));
        usdc.mint(user1, 10000e6);
    }

    function test_EmergencyWithdrawBypassesTimeLock() public {
        uint256 unlockTime = block.timestamp + 365 days;

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, unlockTime, "Locked");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        uint256 balanceBefore = usdc.balanceOf(user1);
        vault.emergencyWithdrawToken(vaultId, address(usdc));
        uint256 balanceAfter = usdc.balanceOf(user1);
        vm.stopPrank();

        assertGt(balanceAfter, balanceBefore);
    }

    function test_EmergencyWithdrawBypassesGoal() public {
        uint256 goalAmount = 10000e6; // Large goal

        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(usdc), goalAmount, 0, "Goal");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);

        uint256 balanceBefore = usdc.balanceOf(user1);
        vault.emergencyWithdrawToken(vaultId, address(usdc));
        uint256 balanceAfter = usdc.balanceOf(user1);
        vm.stopPrank();

        assertGt(balanceAfter, balanceBefore);
    }

    function test_EmergencyWithdrawOnlyByOwner() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vm.stopPrank();

        vm.prank(user2);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.emergencyWithdrawToken(vaultId, address(usdc));
    }

    function test_EmergencyWithdrawZeroBalanceReverts() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.NoTokenBalance.selector);
        vault.emergencyWithdrawToken(vaultId, address(usdc));
    }

    function test_EmergencyWithdrawFromInactiveReverts() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vault.withdrawToken(vaultId, address(usdc));

        vm.expectRevert(TokenSavingsVault.VaultNotActive.selector);
        vault.emergencyWithdrawToken(vaultId, address(usdc));
        vm.stopPrank();
    }
}
