// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;
    MockERC20 public dai;

    address public owner;
    address public user1;
    address public user2;

    uint256 constant INITIAL_BALANCE = 10000e18;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);
        dai = new MockERC20("Dai Stablecoin", "DAI", 18);

        // Whitelist tokens
        vault.whitelistToken(address(usdc));
        vault.whitelistToken(address(dai));

        // Fund users
        usdc.mint(user1, 10000e6);
        usdc.mint(user2, 10000e6);
        dai.mint(user1, INITIAL_BALANCE);
        dai.mint(user2, INITIAL_BALANCE);
    }

    function test_CreateTokenVault() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(
            address(usdc),
            1000e6,
            block.timestamp + 30 days,
            "My USDC Savings"
        );

        assertEq(vaultId, 0);

        (
            address vaultOwner,
            address goalToken,
            uint256 goalAmount,
            uint256 unlockTimestamp,
            bool isActive,
            ,
            string memory metadata
        ) = vault.getTokenVaultDetails(vaultId);

        assertEq(vaultOwner, user1);
        assertEq(goalToken, address(usdc));
        assertEq(goalAmount, 1000e6);
        assertEq(unlockTimestamp, block.timestamp + 30 days);
        assertTrue(isActive);
        assertEq(metadata, "My USDC Savings");
    }

    function test_DepositToken() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Flexible Vault");

        uint256 depositAmount = 1000e6;

        vm.startPrank(user1);
        usdc.approve(address(vault), depositAmount);
        vault.depositToken(vaultId, address(usdc), depositAmount);
        vm.stopPrank();

        uint256 expectedDeposit = depositAmount - (depositAmount * 50 / 10000);
        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), expectedDeposit);
    }

    function test_WithdrawToken() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Flexible Vault");

        uint256 depositAmount = 1000e6;

        vm.startPrank(user1);
        usdc.approve(address(vault), depositAmount);
        vault.depositToken(vaultId, address(usdc), depositAmount);

        uint256 balanceBefore = usdc.balanceOf(user1);
        vault.withdrawToken(vaultId, address(usdc));
        uint256 balanceAfter = usdc.balanceOf(user1);
        vm.stopPrank();

        assertGt(balanceAfter, balanceBefore);
        assertEq(vault.getVaultTokenBalance(vaultId, address(usdc)), 0);
    }
}
