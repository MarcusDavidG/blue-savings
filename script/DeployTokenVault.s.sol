// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/TokenSavingsVault.sol";

/**
 * @title DeployTokenVault
 * @notice Deployment script for TokenSavingsVault
 */
contract DeployTokenVault is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        TokenSavingsVault vault = new TokenSavingsVault();

        console.log("TokenSavingsVault deployed at:", address(vault));

        vm.stopBroadcast();
    }
}
