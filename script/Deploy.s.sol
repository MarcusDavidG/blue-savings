// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {SavingsVault} from "../src/SavingsVault.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        SavingsVault vault = new SavingsVault();
        
        console.log("SavingsVault deployed to:", address(vault));
        console.log("Owner:", vault.owner());
        console.log("Fee BPS:", vault.feeBps());
        
        vm.stopBroadcast();
    }
}
