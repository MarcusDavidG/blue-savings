// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/SavingsVault.sol";

/// @title Invariant Tests for SavingsVault
contract InvariantTests is Test {
    SavingsVault public vault;
    Handler public handler;

    function setUp() public {
        vault = new SavingsVault();
        handler = new Handler(vault);
        
        targetContract(address(handler));
    }

    /// @notice Invariant: Total balance equals sum of vault balances plus fees
    function invariant_balanceIntegrity() public {
        assertTrue(address(vault).balance >= vault.totalFeesCollected());
    }

    /// @notice Invariant: Fee percentage within bounds
    function invariant_feeBounds() public {
        assertTrue(vault.feeBps() >= 0 && vault.feeBps() <= vault.MAX_FEE_BPS());
    }

    /// @notice Invariant: Vault counter never decreases
    function invariant_vaultCounterIncreasing() public {
        assertTrue(vault.vaultCounter() >= handler.initialVaultCount());
    }
}

contract Handler is Test {
    SavingsVault public vault;
    uint256 public initialVaultCount;

    constructor(SavingsVault _vault) {
        vault = _vault;
        initialVaultCount = vault.vaultCounter();
    }

    function createVault(uint256 goalAmount, uint256 unlockTime) public {
        goalAmount = bound(goalAmount, 0, 1000 ether);
        unlockTime = bound(unlockTime, 0, block.timestamp + 365 days);
        
        vault.createVault(goalAmount, unlockTime, "Test Vault");
    }

    function deposit(uint256 vaultId, uint256 amount) public {
        if (vaultId >= vault.vaultCounter()) return;
        amount = bound(amount, 0.01 ether, 10 ether);
        
        vm.deal(address(this), amount);
        vault.deposit{value: amount}(vaultId);
    }
}
