// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {SavingsVault} from "../src/SavingsVault.sol";

/// @title Interact Script
/// @notice Interactive scripts for deployed SavingsVault
contract InteractScript is Script {
    function run() external view {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        
        console.log("=== SavingsVault Info ===");
        console.log("Address:", vaultAddress);
        console.log("Owner:", vault.owner());
        console.log("Fee BPS:", vault.feeBps());
        console.log("Total Fees Collected:", vault.totalFeesCollected());
        console.log("Vault Counter:", vault.vaultCounter());
    }
}

contract CreateVaultScript is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        
        uint256 goalAmount = vm.envOr("GOAL_AMOUNT", uint256(0));
        uint256 unlockTimestamp = vm.envOr("UNLOCK_TIMESTAMP", uint256(0));
        string memory metadata = vm.envOr("METADATA", string("My Vault"));
        
        vm.startBroadcast(userPrivateKey);
        
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        uint256 vaultId = vault.createVault(goalAmount, unlockTimestamp, metadata);
        
        console.log("Created vault ID:", vaultId);
        console.log("Goal Amount:", goalAmount);
        console.log("Unlock Timestamp:", unlockTimestamp);
        console.log("Metadata:", metadata);
        
        vm.stopBroadcast();
    }
}

contract DepositScript is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        uint256 vaultId = vm.envUint("VAULT_ID");
        uint256 depositAmount = vm.envUint("DEPOSIT_AMOUNT");
        
        vm.startBroadcast(userPrivateKey);
        
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        
        (uint256 fee, uint256 net) = vault.calculateDepositFee(depositAmount);
        console.log("Depositing:", depositAmount);
        console.log("Fee:", fee);
        console.log("Net deposit:", net);
        
        vault.deposit{value: depositAmount}(vaultId);
        
        console.log("Deposit successful to vault:", vaultId);
        
        vm.stopBroadcast();
    }
}

contract WithdrawScript is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        uint256 vaultId = vm.envUint("VAULT_ID");
        
        vm.startBroadcast(userPrivateKey);
        
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        
        (,uint256 balance,,,bool isActive,,,bool canWithdraw) = vault.getVaultDetails(vaultId);
        
        console.log("Vault balance:", balance);
        console.log("Is active:", isActive);
        console.log("Can withdraw:", canWithdraw);
        
        if (canWithdraw) {
            vault.withdraw(vaultId);
            console.log("Withdrawal successful from vault:", vaultId);
        } else {
            console.log("Cannot withdraw yet - conditions not met");
        }
        
        vm.stopBroadcast();
    }
}

contract GetVaultDetailsScript is Script {
    function run() external view {
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        uint256 vaultId = vm.envUint("VAULT_ID");
        
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        
        (
            address owner,
            uint256 balance,
            uint256 goalAmount,
            uint256 unlockTimestamp,
            bool isActive,
            uint256 createdAt,
            string memory metadata,
            bool canWithdraw
        ) = vault.getVaultDetails(vaultId);
        
        console.log("=== Vault", vaultId, "Details ===");
        console.log("Owner:", owner);
        console.log("Balance:", balance);
        console.log("Goal Amount:", goalAmount);
        console.log("Unlock Timestamp:", unlockTimestamp);
        console.log("Is Active:", isActive);
        console.log("Created At:", createdAt);
        console.log("Metadata:", metadata);
        console.log("Can Withdraw:", canWithdraw);
    }
}

contract SetMetadataScript is Script {
    function run() external {
        uint256 userPrivateKey = vm.envUint("PRIVATE_KEY");
        address vaultAddress = vm.envAddress("VAULT_ADDRESS");
        uint256 vaultId = vm.envUint("VAULT_ID");
        string memory metadata = vm.envString("METADATA");
        
        vm.startBroadcast(userPrivateKey);
        
        SavingsVault vault = SavingsVault(payable(vaultAddress));
        vault.setVaultMetadata(vaultId, metadata);
        
        console.log("Metadata updated for vault:", vaultId);
        console.log("New metadata:", metadata);
        
        vm.stopBroadcast();
    }
}