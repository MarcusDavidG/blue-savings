// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {RecurringDeposit} from "../src/RecurringDeposit.sol";

/**
 * @title DeployRecurringDeposit
 * @notice Deployment script for RecurringDeposit on Base mainnet
 */
contract DeployRecurringDepositScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envOr("TOKEN_SAVINGS_VAULT_ADDRESS", address(0));

        require(vaultAddress != address(0), "TOKEN_SAVINGS_VAULT_ADDRESS not set");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy RecurringDeposit
        RecurringDeposit recurringDeposit = new RecurringDeposit(vaultAddress);
        console.log("RecurringDeposit deployed to:", address(recurringDeposit));
        console.log("Vault contract:", vaultAddress);
        console.log("Owner:", recurringDeposit.owner());

        // Log Chainlink Automation info
        console.log("");
        console.log("Chainlink Automation Setup:");
        console.log("- Register upkeep at: https://automation.chain.link/base");
        console.log("- Use contract address:", address(recurringDeposit));
        console.log("- checkUpkeep and performUpkeep are implemented");
        console.log("- Estimated gas per execution:", recurringDeposit.estimateExecutionGas());

        vm.stopBroadcast();
    }
}
