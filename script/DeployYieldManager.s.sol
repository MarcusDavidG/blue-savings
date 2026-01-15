// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {YieldManager} from "../src/yield/YieldManager.sol";
import {AaveV3Adapter} from "../src/yield/AaveV3Adapter.sol";
import {CompoundV3Adapter} from "../src/yield/CompoundV3Adapter.sol";

/**
 * @title DeployYieldManager
 * @notice Deployment script for YieldManager and yield adapters on Base mainnet
 */
contract DeployYieldManagerScript is Script {
    // Base mainnet addresses
    address constant AAVE_V3_POOL = 0xA238Dd80C259a72e81d7e4664a9801593F98d1c5;
    address constant COMPOUND_V3_USDC = 0x9c4ec768c28520B50860ea7a15bd7213a9fF58bf;

    // aToken addresses on Base
    address constant A_USDC = 0x4e65fE4DbA92790696d040ac24Aa414708F5c0AB;
    address constant A_WETH = 0xD4a0e0b9149BCee3C920d2E00b5dE09138fd8bb7;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envOr("TOKEN_SAVINGS_VAULT_ADDRESS", address(0));

        require(vaultAddress != address(0), "TOKEN_SAVINGS_VAULT_ADDRESS not set");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy YieldManager
        YieldManager yieldManager = new YieldManager(vaultAddress);
        console.log("YieldManager deployed to:", address(yieldManager));

        // Deploy Aave adapter
        AaveV3Adapter aaveAdapter = new AaveV3Adapter(address(yieldManager), AAVE_V3_POOL);
        console.log("AaveV3Adapter deployed to:", address(aaveAdapter));

        // Configure aTokens
        aaveAdapter.setAToken(0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913, A_USDC); // USDC
        aaveAdapter.setAToken(0x4200000000000000000000000000000000000006, A_WETH); // WETH

        // Deploy Compound adapter
        CompoundV3Adapter compoundAdapter = new CompoundV3Adapter(address(yieldManager), COMPOUND_V3_USDC);
        console.log("CompoundV3Adapter deployed to:", address(compoundAdapter));

        // Register adapters
        yieldManager.addAdapter(address(aaveAdapter));
        yieldManager.addAdapter(address(compoundAdapter));

        console.log("Deployment complete!");
        console.log("-------------------");
        console.log("YieldManager:", address(yieldManager));
        console.log("AaveV3Adapter:", address(aaveAdapter));
        console.log("CompoundV3Adapter:", address(compoundAdapter));

        vm.stopBroadcast();
    }
}
