// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TokenSavingsVault.sol";
import "../src/BaseTokenAddresses.sol";

/**
 * @title SetupBase
 * @notice Configure contracts for Base mainnet
 */
contract SetupBase is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenVaultAddress = vm.envAddress("TOKEN_VAULT_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        TokenSavingsVault vault = TokenSavingsVault(tokenVaultAddress);

        // Whitelist Base mainnet tokens
        vault.whitelistToken(BaseTokenAddresses.USDC);
        vault.whitelistToken(BaseTokenAddresses.DAI);
        vault.whitelistToken(BaseTokenAddresses.USDbC);
        vault.whitelistToken(BaseTokenAddresses.WETH);
        vault.whitelistToken(BaseTokenAddresses.cbETH);

        console.log("Whitelisted 5 tokens on Base mainnet");

        vm.stopBroadcast();
    }
}
