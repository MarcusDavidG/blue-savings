// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultDepositTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;
    MockERC20 public dai;

    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);
        dai = new MockERC20("Dai Stablecoin", "DAI", 18);

        vault.whitelistToken(address(usdc));
        vault.whitelistToken(address(dai));

        usdc.mint(user1, 10000e6);
        dai.mint(user1, 10000e18);
    }

    function test_DepositDeductsFee() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        uint256 depositAmount = 1000e6;
        uint256 expectedFee = (depositAmount * 50) / 10000; // 0.5%
        uint256 expectedDeposit = depositAmount - expectedFee;

        vm.startPrank(user1);
        usdc.approve(address(vault), depositAmount);
        vault.depositToken(vaultId, address(usdc), depositAmount);
        vm.stopPrank();

        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), expectedDeposit);
        assertEq(vault.getTokenFees(address(usdc)), expectedFee);
    }

    function test_DepositMultipleTokens() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Multi-token");

        vm.startPrank(user1);
        usdc.approve(address(vault), 500e6);
        vault.depositToken(vaultId, address(usdc), 500e6);

        dai.approve(address(vault), 500e18);
        vault.depositToken(vaultId, address(dai), 500e18);
        vm.stopPrank();

        address[] memory tokens = vault.getVaultTokens(vaultId);
        assertEq(tokens.length, 2);
        assertGt(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
        assertGt(vault.getVaultTokenBalance(vaultId, address(dai)), 0);
    }

    function test_DepositToInactiveVaultReverts() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        // Deposit and withdraw to deactivate
        vm.startPrank(user1);
        usdc.approve(address(vault), 500e6);
        vault.depositToken(vaultId, address(usdc), 500e6);
        vault.withdrawToken(vaultId, address(usdc));

        // Try to deposit again
        usdc.approve(address(vault), 500e6);
        vm.expectRevert(TokenSavingsVault.VaultNotActive.selector);
        vault.depositToken(vaultId, address(usdc), 500e6);
        vm.stopPrank();
    }

    function test_DepositZeroAmountReverts() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vm.expectRevert(TokenSavingsVault.InvalidAmount.selector);
        vault.depositToken(vaultId, address(usdc), 0);
        vm.stopPrank();
    }

    function test_AnyoneCanDeposit() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        usdc.mint(user2, 1000e6);

        vm.startPrank(user2);
        usdc.approve(address(vault), 500e6);
        vault.depositToken(vaultId, address(usdc), 500e6);
        vm.stopPrank();

        assertGt(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
    }

    function test_DepositEmitsEvent() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        uint256 depositAmount = 1000e6;
        uint256 expectedFee = (depositAmount * 50) / 10000;
        uint256 expectedDeposit = depositAmount - expectedFee;

        vm.startPrank(user1);
        usdc.approve(address(vault), depositAmount);

        vm.expectEmit(true, true, true, true);
        emit TokenSavingsVault.TokenDeposited(vaultId, user1, address(usdc), expectedDeposit, expectedFee);

        vault.depositToken(vaultId, address(usdc), depositAmount);
        vm.stopPrank();
    }
}
