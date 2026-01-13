// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";

/**
 * @title VerifyContracts
 * @notice Verify all contracts on BaseScan
 */
contract VerifyContracts is Script {
    function run() external view {
        console.log("To verify contracts on BaseScan:");
        console.log("");
        console.log("1. SavingsVault:");
        console.log("   forge verify-contract <address> SavingsVault --chain base");
        console.log("");
        console.log("2. TokenSavingsVault:");
        console.log("   forge verify-contract <address> TokenSavingsVault --chain base");
        console.log("");
        console.log("3. RecurringDeposit:");
        console.log("   forge verify-contract <address> RecurringDeposit --chain base");
        console.log("");
        console.log("4. VaultTemplateRegistry:");
        console.log("   forge verify-contract <address> VaultTemplateRegistry --chain base");
        console.log("");
        console.log("5. ReferralSystem:");
        console.log("   forge verify-contract <address> ReferralSystem --chain base");
    }
}
