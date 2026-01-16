// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {BasenameResolver} from "../src/integration/BasenameResolver.sol";

/**
 * @title DeployBasenameResolver
 * @notice Deployment script for BasenameResolver on Base mainnet
 */
contract DeployBasenameResolverScript is Script {
    // Base Name Service Registry on Base mainnet
    address constant BASENAME_REGISTRY = 0x4cCb0BB02FCABA27e82a56646E81d8c5bC4119a5;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        BasenameResolver resolver = new BasenameResolver(BASENAME_REGISTRY);

        console.log("BasenameResolver deployed to:", address(resolver));
        console.log("Registry:", BASENAME_REGISTRY);
        console.log("Owner:", resolver.owner());

        vm.stopBroadcast();
    }
}
