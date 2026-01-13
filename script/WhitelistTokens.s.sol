// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TokenSavingsVault.sol";
import "../src/BaseTokenAddresses.sol";

/**
 * @title WhitelistTokens
 * @notice Script to whitelist common tokens on Base
 */
contract WhitelistTokens is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("TOKEN_VAULT_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        TokenSavingsVault vault = TokenSavingsVault(vaultAddress);

        // Whitelist stablecoins
        vault.whitelistToken(BaseTokenAddresses.USDC);
        console.log("Whitelisted USDC");

        vault.whitelistToken(BaseTokenAddresses.DAI);
        console.log("Whitelisted DAI");

        vault.whitelistToken(BaseTokenAddresses.USDbC);
        console.log("Whitelisted USDbC");

        // Whitelist WETH
        vault.whitelistToken(BaseTokenAddresses.WETH);
        console.log("Whitelisted WETH");

        // Whitelist cbETH
        vault.whitelistToken(BaseTokenAddresses.cbETH);
        console.log("Whitelisted cbETH");

        vm.stopBroadcast();
    }
}
