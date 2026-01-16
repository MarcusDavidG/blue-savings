// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {AerodromeAdapter} from "../src/integration/AerodromeAdapter.sol";

/**
 * @title DeployAerodromeAdapter
 * @notice Deployment script for AerodromeAdapter on Base mainnet
 */
contract DeployAerodromeAdapterScript is Script {
    // Aerodrome Router V2 on Base mainnet
    address constant AERODROME_ROUTER = 0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        AerodromeAdapter adapter = new AerodromeAdapter(AERODROME_ROUTER);

        console.log("AerodromeAdapter deployed to:", address(adapter));
        console.log("Router:", AERODROME_ROUTER);
        console.log("Owner:", adapter.owner());

        vm.stopBroadcast();
    }
}
