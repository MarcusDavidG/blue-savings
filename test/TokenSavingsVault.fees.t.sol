// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultFeesTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;

    address public owner;
    address public user1;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);

        vault.whitelistToken(address(usdc));
        usdc.mint(user1, 10000e6);
    }

    function test_CollectTokenFees() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vm.stopPrank();

        uint256 expectedFee = (1000e6 * 50) / 10000;
        assertEq(vault.getTokenFees(address(usdc)), expectedFee);

        uint256 ownerBalanceBefore = usdc.balanceOf(owner);
        vault.collectTokenFees(address(usdc));
        uint256 ownerBalanceAfter = usdc.balanceOf(owner);

        assertEq(ownerBalanceAfter - ownerBalanceBefore, expectedFee);
        assertEq(vault.getTokenFees(address(usdc)), 0);
    }

    function test_SetTokenFeeBps() public {
        uint256 newFee = 100; // 1%

        vault.setTokenFeeBps(newFee);

        assertEq(vault.tokenFeeBps(), newFee);
    }

    function test_SetTokenFeeBps_MaxFeeReverts() public {
        uint256 invalidFee = 201; // > 2%

        vm.expectRevert(TokenSavingsVault.InvalidFee.selector);
        vault.setTokenFeeBps(invalidFee);
    }

    function test_SetTokenFeeBps_OnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.setTokenFeeBps(100);
    }

    function test_CollectTokenFees_OnlyOwner() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vm.stopPrank();

        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.collectTokenFees(address(usdc));
    }

    function test_CollectZeroFeesReverts() public {
        vm.expectRevert(TokenSavingsVault.InvalidAmount.selector);
        vault.collectTokenFees(address(usdc));
    }

    function test_FeesAccumulateAcrossDeposits() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        vm.startPrank(user1);
        usdc.approve(address(vault), 3000e6);
        
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vault.depositToken(vaultId, address(usdc), 1000e6);
        vm.stopPrank();

        uint256 expectedTotalFee = 3 * ((1000e6 * 50) / 10000);
        assertEq(vault.getTokenFees(address(usdc)), expectedTotalFee);
    }

    function test_SetFeeBpsEmitsEvent() public {
        vm.expectEmit(true, true, true, true);
        emit TokenSavingsVault.TokenFeeBpsUpdated(50, 100);
        
        vault.setTokenFeeBps(100);
    }
}
