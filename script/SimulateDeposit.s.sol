// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/SavingsVault.sol";

/**
 * @title SimulateDeposit
 * @notice Simulate a deposit on local fork
 */
contract SimulateDeposit is Script {
    function run() external {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        uint256 vaultId = vm.envUint("VAULT_ID");
        uint256 amount = vm.envUint("DEPOSIT_AMOUNT");

        SavingsVault vault = SavingsVault(vaultAddress);

        console.log("Vault:", vaultAddress);
        console.log("Vault ID:", vaultId);
        console.log("Amount:", amount);

        vm.startBroadcast();
        vault.deposit{value: amount}(vaultId);
        vm.stopBroadcast();

        console.log("Deposit successful");
    }
}
