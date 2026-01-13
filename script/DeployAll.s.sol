// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SavingsVault.sol";
import "../src/TokenSavingsVault.sol";
import "../src/RecurringDeposit.sol";
import "../src/VaultTemplateRegistry.sol";
import "../src/ReferralSystem.sol";

/**
 * @title DeployAll
 * @notice Deploy all BlueSavings contracts
 */
contract DeployAll is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        // Core vaults
        SavingsVault savingsVault = new SavingsVault();
        console.log("SavingsVault:", address(savingsVault));

        TokenSavingsVault tokenVault = new TokenSavingsVault();
        console.log("TokenSavingsVault:", address(tokenVault));

        // Recurring deposits
        RecurringDeposit recurring = new RecurringDeposit(address(tokenVault));
        console.log("RecurringDeposit:", address(recurring));

        // Templates
        VaultTemplateRegistry templates = new VaultTemplateRegistry();
        console.log("VaultTemplateRegistry:", address(templates));

        // Referrals
        ReferralSystem referrals = new ReferralSystem();
        console.log("ReferralSystem:", address(referrals));

        vm.stopBroadcast();
    }
}
