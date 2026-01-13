// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract TokenSavingsVaultWhitelistTest is Test {
    TokenSavingsVault public vault;
    MockERC20 public usdc;
    MockERC20 public dai;
    MockERC20 public unlistedToken;

    address public owner;
    address public user1;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");

        vault = new TokenSavingsVault();
        usdc = new MockERC20("USD Coin", "USDC", 6);
        dai = new MockERC20("Dai Stablecoin", "DAI", 18);
        unlistedToken = new MockERC20("Unlisted", "UNL", 18);

        vault.whitelistToken(address(usdc));
    }

    function test_WhitelistToken() public {
        assertFalse(vault.isTokenWhitelisted(address(dai)));
        
        vault.whitelistToken(address(dai));
        
        assertTrue(vault.isTokenWhitelisted(address(dai)));
        assertEq(vault.getWhitelistedTokenCount(), 2);
    }

    function test_DelistToken() public {
        assertTrue(vault.isTokenWhitelisted(address(usdc)));
        
        vault.delistToken(address(usdc));
        
        assertFalse(vault.isTokenWhitelisted(address(usdc)));
        assertEq(vault.getWhitelistedTokenCount(), 0);
    }

    function test_RevertWhenDepositingUnlistedToken() public {
        vm.prank(user1);
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");

        unlistedToken.mint(user1, 1000e18);

        vm.startPrank(user1);
        unlistedToken.approve(address(vault), 1000e18);
        
        vm.expectRevert(abi.encodeWithSelector(
            TokenWhitelist.TokenNotWhitelisted.selector,
            address(unlistedToken)
        ));
        vault.depositToken(vaultId, address(unlistedToken), 1000e18);
        vm.stopPrank();
    }

    function test_RevertWhenWhitelistingZeroAddress() public {
        vm.expectRevert(TokenWhitelist.InvalidTokenAddress.selector);
        vault.whitelistToken(address(0));
    }

    function test_RevertWhenWhitelistingAlreadyWhitelisted() public {
        vm.expectRevert(abi.encodeWithSelector(
            TokenWhitelist.TokenAlreadyWhitelisted.selector,
            address(usdc)
        ));
        vault.whitelistToken(address(usdc));
    }

    function test_RevertWhenDelistingNotWhitelisted() public {
        vm.expectRevert(abi.encodeWithSelector(
            TokenWhitelist.TokenNotWhitelisted.selector,
            address(dai)
        ));
        vault.delistToken(address(dai));
    }

    function test_GetWhitelistedTokens() public {
        vault.whitelistToken(address(dai));

        address[] memory tokens = vault.getWhitelistedTokens();
        
        assertEq(tokens.length, 2);
        assertEq(tokens[0], address(usdc));
        assertEq(tokens[1], address(dai));
    }

    function test_OnlyOwnerCanWhitelist() public {
        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.whitelistToken(address(dai));
    }

    function test_OnlyOwnerCanDelist() public {
        vm.prank(user1);
        vm.expectRevert(TokenSavingsVault.Unauthorized.selector);
        vault.delistToken(address(usdc));
    }
}
