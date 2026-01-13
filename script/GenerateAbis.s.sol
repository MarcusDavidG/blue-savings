// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

/**
 * @title GenerateAbis
 * @notice Generate ABIs for frontend
 */
contract GenerateAbis is Script {
    function run() external view {
        console.log("ABIs are generated in out/ directory after build");
        console.log("");
        console.log("Key ABIs for frontend:");
        console.log("- out/SavingsVault.sol/SavingsVault.json");
        console.log("- out/TokenSavingsVault.sol/TokenSavingsVault.json");
        console.log("- out/RecurringDeposit.sol/RecurringDeposit.json");
        console.log("- out/VaultTemplateRegistry.sol/VaultTemplateRegistry.json");
        console.log("- out/ReferralSystem.sol/ReferralSystem.json");
        console.log("- out/VaultReceiptNFT.sol/VaultReceiptNFT.json");
        console.log("");
        console.log("To extract ABI only:");
        console.log("jq '.abi' out/SavingsVault.sol/SavingsVault.json > frontend/abi/SavingsVault.json");
    }
}
