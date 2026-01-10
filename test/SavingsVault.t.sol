// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SavingsVault} from "../src/SavingsVault.sol";

contract SavingsVaultTest is Test {
    SavingsVault public vault;
    
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    event VaultCreated(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string metadata
    );
    
    event VaultMetadataUpdated(
        uint256 indexed vaultId,
        string metadata
    );
    
    event Deposited(
        uint256 indexed vaultId,
        address indexed depositor,
        uint256 amount,
        uint256 feeAmount
    );
    
    event Withdrawn(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 amount
    );
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setUp() public {
        vm.prank(owner);
        vault = new SavingsVault();
        
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }
    
    function testCreateVaultWithTimeLock() public {
        vm.startPrank(user1);
        
        uint256 unlockTime = block.timestamp + 30 days;
        
        vm.expectEmit(true, true, false, true);
        emit VaultCreated(0, user1, 0, unlockTime, "Time Lock Vault");
        
        uint256 vaultId = vault.createVault(0, unlockTime, "Time Lock Vault");
        
        (address vaultOwner, , , uint256 timestamp, bool isActive, ,,) = vault.getVaultDetails(vaultId);
        
        assertEq(vaultOwner, user1);
        assertEq(timestamp, unlockTime);
        assertTrue(isActive);
        
        vm.stopPrank();
    }
    
    function testCreateVaultWithGoal() public {
        vm.startPrank(user1);
        
        uint256 goalAmount = 10 ether;
        uint256 vaultId = vault.createVault(goalAmount, 0, "Goal Vault");
        
        (, , uint256 goal, , bool isActive, ,,) = vault.getVaultDetails(vaultId);
        
        assertEq(goal, goalAmount);
        assertTrue(isActive);
        
        vm.stopPrank();
    }
    
    function testDepositToVault() public {
        vm.startPrank(user1);
        
        uint256 vaultId = vault.createVault(0, 0, "Test Vault");
        uint256 depositAmount = 1 ether;
        
        (uint256 expectedFee, uint256 expectedNet) = vault.calculateDepositFee(depositAmount);
        
        vm.expectEmit(true, true, false, true);
        emit Deposited(vaultId, user1, expectedNet, expectedFee);
        
        vault.deposit{value: depositAmount}(vaultId);
        
        (, uint256 balance, , , , ,,) = vault.getVaultDetails(vaultId);
        
        assertEq(balance, expectedNet);
        assertEq(vault.totalFeesCollected(), expectedFee);
        
        vm.stopPrank();
    }
    
    function testMultipleDeposits() public {
        vm.startPrank(user1);
        
        uint256 vaultId = vault.createVault(0, 0, "Multi Deposit Vault");
        
        vault.deposit{value: 1 ether}(vaultId);
        vault.deposit{value: 2 ether}(vaultId);
        vault.deposit{value: 0.5 ether}(vaultId);
        
        (, uint256 balance, , , , ,,) = vault.getVaultDetails(vaultId);
        
        (, uint256 totalNet) = vault.calculateDepositFee(3.5 ether);
        
        assertEq(balance, totalNet);
        
        vm.stopPrank();
    }
    
    function testWithdrawAfterTimeLock() public {
        vm.startPrank(user1);
        
        uint256 unlockTime = block.timestamp + 30 days;
        uint256 vaultId = vault.createVault(0, unlockTime, "Locked Vault");
        
        vault.deposit{value: 1 ether}(vaultId);
        
        vm.expectRevert(SavingsVault.VaultLocked.selector);
        vault.withdraw(vaultId);
        
        vm.warp(unlockTime);
        
        uint256 balanceBefore = user1.balance;
        vault.withdraw(vaultId);
        
        (, , , , bool isActive, ,,) = vault.getVaultDetails(vaultId);
        
        assertFalse(isActive);
        assertGt(user1.balance, balanceBefore);
        
        vm.stopPrank();
    }
    
    function testWithdrawAfterGoalReached() public {
        vm.startPrank(user1);
        
        uint256 goalAmount = 5 ether;
        uint256 vaultId = vault.createVault(goalAmount, 0, "Goal Vault");
        
        vault.deposit{value: 3 ether}(vaultId);
        
        vm.expectRevert(SavingsVault.GoalNotReached.selector);
        vault.withdraw(vaultId);
        
        vault.deposit{value: 3 ether}(vaultId);
        
        uint256 balanceBefore = user1.balance;
        vault.withdraw(vaultId);
        
        assertGt(user1.balance, balanceBefore);
        
        vm.stopPrank();
    }
    
    function testEmergencyWithdraw() public {
        vm.startPrank(user1);
        
        uint256 unlockTime = block.timestamp + 365 days;
        uint256 vaultId = vault.createVault(0, unlockTime, "Emergency Test");
        
        vault.deposit{value: 5 ether}(vaultId);
        
        uint256 balanceBefore = user1.balance;
        vault.emergencyWithdraw(vaultId);
        
        (, , , , bool isActive, ,,) = vault.getVaultDetails(vaultId);
        
        assertFalse(isActive);
        assertGt(user1.balance, balanceBefore);
        
        vm.stopPrank();
    }
    
    function testOnlyVaultOwnerCanWithdraw() public {
        vm.prank(user1);
        uint256 vaultId = vault.createVault(0, 0, "User1 Vault");
        
        vm.prank(user1);
        vault.deposit{value: 1 ether}(vaultId);
        
        vm.prank(user2);
        vm.expectRevert(SavingsVault.Unauthorized.selector);
        vault.withdraw(vaultId);
    }
    
    function testOwnerCanCollectFees() public {
        vm.prank(user1);
        uint256 vaultId = vault.createVault(0, 0, "Fee Test Vault");
        
        vm.prank(user1);
        vault.deposit{value: 10 ether}(vaultId);
        
        uint256 expectedFees = vault.totalFeesCollected();
        
        vm.prank(owner);
        uint256 balanceBefore = owner.balance;
        vault.collectFees();
        
        assertEq(owner.balance, balanceBefore + expectedFees);
        assertEq(vault.totalFeesCollected(), 0);
    }
    
    function testOnlyOwnerCanCollectFees() public {
        vm.prank(user1);
        vm.expectRevert(SavingsVault.Unauthorized.selector);
        vault.collectFees();
    }
    
    function testSetFeeBps() public {
        vm.startPrank(owner);
        
        uint256 newFee = 100; // 1%
        vault.setFeeBps(newFee);
        
        assertEq(vault.feeBps(), newFee);
        
        vm.stopPrank();
    }
    
    function testCannotSetFeeTooHigh() public {
        vm.startPrank(owner);
        
        vm.expectRevert(SavingsVault.InvalidFee.selector);
        vault.setFeeBps(300); // 3% > MAX_FEE_BPS
        
        vm.stopPrank();
    }
    
    function testGetUserVaults() public {
        vm.startPrank(user1);
        
        vault.createVault(0, block.timestamp + 30 days, "Vault 1");
        vault.createVault(1 ether, 0, "Vault 2");
        vault.createVault(0, 0, "Vault 3");
        
        uint256[] memory userVaults = vault.getUserVaults(user1);
        
        assertEq(userVaults.length, 3);
        assertEq(userVaults[0], 0);
        assertEq(userVaults[1], 1);
        assertEq(userVaults[2], 2);
        
        vm.stopPrank();
    }
    
    function testCannotDepositZero() public {
        vm.startPrank(user1);
        
        uint256 vaultId = vault.createVault(0, 0, "Zero Test");
        
        vm.expectRevert(SavingsVault.InvalidAmount.selector);
        vault.deposit{value: 0}(vaultId);
        
        vm.stopPrank();
    }
    
    function testCannotCreateVaultWithPastTimestamp() public {
        vm.startPrank(user1);
        
        vm.warp(1000);
        
        vm.expectRevert(SavingsVault.InvalidParameters.selector);
        vault.createVault(0, 999, "Past Vault");
        
        vm.stopPrank();
    }
    
    function testTransferOwnership() public {
        vm.startPrank(owner);
        
        address newOwner = address(100);
        vault.transferOwnership(newOwner);
        
        assertEq(vault.owner(), newOwner);
        
        vm.stopPrank();
    }
    
    function testFuzzDeposit(uint96 amount) public {
        vm.assume(amount > 0.001 ether && amount < 50 ether);
        
        vm.startPrank(user1);
        
        uint256 vaultId = vault.createVault(0, 0, "Fuzz Vault");
        
        (uint256 expectedFee, uint256 expectedNet) = vault.calculateDepositFee(amount);
        
        vault.deposit{value: amount}(vaultId);
        
        (, uint256 balance, , , , ,,) = vault.getVaultDetails(vaultId);
        
        assertEq(balance, expectedNet);
        assertEq(vault.totalFeesCollected(), expectedFee);
        
        vm.stopPrank();
    }
    
    function testCanWithdrawView() public {
        vm.startPrank(user1);
        
        uint256 unlockTime = block.timestamp + 30 days;
        uint256 vaultId = vault.createVault(0, unlockTime, "View Test");
        
        vault.deposit{value: 1 ether}(vaultId);
        
        (, , , , , ,, bool canWithdraw) = vault.getVaultDetails(vaultId);
        assertFalse(canWithdraw);
        
        vm.warp(unlockTime);
        
        (, , , , , ,, canWithdraw) = vault.getVaultDetails(vaultId);
        assertTrue(canWithdraw);
        
        vm.stopPrank();
    }
    
    function testCreateVaultWithMetadata() public {
        vm.startPrank(user1);
        
        string memory metadata = "Emergency Fund";
        uint256 vaultId = vault.createVault(0, 0, metadata);
        
        (,,,,,, string memory storedMetadata,) = vault.getVaultDetails(vaultId);
        assertEq(storedMetadata, metadata);
        
        vm.stopPrank();
    }
    
    function testSetVaultMetadata() public {
        vm.startPrank(user1);
        
        uint256 vaultId = vault.createVault(0, 0, "Initial");
        
        vault.setVaultMetadata(vaultId, "Updated Name");
        
        (,,,,,, string memory metadata,) = vault.getVaultDetails(vaultId);
        assertEq(metadata, "Updated Name");
        
        vm.stopPrank();
    }
    
    function testOnlyOwnerCanSetMetadata() public {
        vm.prank(user1);
        uint256 vaultId = vault.createVault(0, 0, "User1 Vault");
        
        vm.prank(user2);
        vm.expectRevert(SavingsVault.Unauthorized.selector);
        vault.setVaultMetadata(vaultId, "Hacked");
    }
    
    function testMetadataEventEmission() public {
        vm.startPrank(user1);
        
        vm.expectEmit(true, true, false, true);
        emit VaultCreated(0, user1, 0, 0, "Test Vault");
        vault.createVault(0, 0, "Test Vault");
        
        vm.expectEmit(true, false, false, true);
        emit VaultMetadataUpdated(0, "New Name");
        vault.setVaultMetadata(0, "New Name");
        
        vm.stopPrank();
    }
    
    function testEmptyMetadata() public {
        vm.prank(user1);
        uint256 vaultId = vault.createVault(0, 0, "");
        
        (,,,,,, string memory metadata,) = vault.getVaultDetails(vaultId);
        assertEq(metadata, "");
    }

    function testCreateVaultWithZeroGoal() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "No Goal Vault");

        (, , uint256 goal, , , ,,) = vault.getVaultDetails(vaultId);

        assertEq(goal, 0, "Goal should be zero");

        vm.stopPrank();
    }

    function testCreateVaultWithZeroTimestamp() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "Immediate Access");

        (, , , uint256 unlockTime, , ,,) = vault.getVaultDetails(vaultId);

        assertEq(unlockTime, 0, "Unlock time should be zero");

        vm.stopPrank();
    }

    function testSetMaximumFee() public {
        vm.prank(owner);

        vault.setFeeBps(200); // MAX_FEE_BPS

        assertEq(vault.feeBps(), 200, "Fee should be set to max");
    }

    function testCannotSetFeeAboveMaximum() public {
        vm.startPrank(owner);

        vm.expectRevert(SavingsVault.InvalidFee.selector);
        vault.setFeeBps(300); // 3% > MAX_FEE_BPS
        
        vm.stopPrank();
    }

    function testDepositLargeAmount() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "Large Deposit Vault");

        vm.deal(user1, 1000 ether);
        uint256 depositAmount = 500 ether;

        vault.deposit{value: depositAmount}(vaultId);

        (, uint256 balance, , , , ,,) = vault.getVaultDetails(vaultId);

        (uint256 expectedFee, uint256 expectedNet) = vault.calculateDepositFee(depositAmount);
        assertEq(balance, expectedNet, "Balance should match net deposit");

        vm.stopPrank();
    }

    function testCreateVaultWithLongMetadata() public {
        vm.startPrank(user1);

        string memory longMetadata = "This is a very long metadata string that contains a lot of characters to test how the contract handles long strings in the metadata field for vault creation";

        uint256 vaultId = vault.createVault(0, 0, longMetadata);

        (, , , , , , string memory storedMetadata,) = vault.getVaultDetails(vaultId);

        assertEq(storedMetadata, longMetadata, "Metadata should match");

        vm.stopPrank();
    }

    function testMetadataWithSpecialCharacters() public {
        vm.startPrank(user1);

        string memory specialMetadata = "Test!@#$%^&*()_+-=[]{}|;:',.<>?";

        uint256 vaultId = vault.createVault(0, 0, specialMetadata);

        (, , , , , , string memory storedMetadata,) = vault.getVaultDetails(vaultId);

        assertEq(storedMetadata, specialMetadata, "Special characters should be preserved");

        vm.stopPrank();
    }

    function testUserCanCreateMultipleVaults() public {
        vm.startPrank(user1);

        uint256 vault1 = vault.createVault(1 ether, 0, "Vault 1");
        uint256 vault2 = vault.createVault(2 ether, 0, "Vault 2");
        uint256 vault3 = vault.createVault(3 ether, 0, "Vault 3");

        uint256[] memory userVaults = vault.getUserVaults(user1);

        assertEq(userVaults.length, 3);
        assertEq(userVaults[0], vault1);
        assertEq(userVaults[1], vault2);
        assertEq(userVaults[2], vault3);

        vm.stopPrank();
    }

    function testVaultCounterIncrementsCorrectly() public {
        uint256 initialCounter = vault.vaultCounter();

        vm.prank(user1);
        vault.createVault(0, 0, "First");

        assertEq(vault.vaultCounter(), initialCounter + 1, "Counter should increment by 1");

        vm.prank(user2);
        vault.createVault(0, 0, "Second");

        assertEq(vault.vaultCounter(), initialCounter + 2, "Counter should increment by 2");
    }

    function testCannotDepositToInactiveVault() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "Test");
        vault.deposit{value: 1 ether}(vaultId);

        // Withdraw to deactivate
        vault.emergencyWithdraw(vaultId);

        // Try to deposit again
        vm.expectRevert(SavingsVault.VaultNotActive.selector);
        vault.deposit{value: 1 ether}(vaultId);

        vm.stopPrank();
    }

    function testCannotWithdrawFromInactiveVault() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "Test");
        vault.deposit{value: 1 ether}(vaultId);
        vault.emergencyWithdraw(vaultId);

        // Try to withdraw again
        vm.expectRevert(SavingsVault.VaultNotActive.selector);
        vault.withdraw(vaultId);

        vm.stopPrank();
    }

    function testFeeCalculationPrecision() public {
        uint256 amount = 1 ether;

        (uint256 fee, uint256 netDeposit) = vault.calculateDepositFee(amount);

        assertEq(fee, (amount * 50) / 10000, "Fee calculation should be precise");
        assertEq(fee + netDeposit, amount, "Fee plus net should equal amount");
    }

    function testWithdrawExactlyAtUnlockTime() public {
        vm.startPrank(user1);

        uint256 unlockTime = block.timestamp + 1 days;
        uint256 vaultId = vault.createVault(0, unlockTime, "Unlock Test");
        vault.deposit{value: 1 ether}(vaultId);

        // Move to exactly unlock time
        vm.warp(unlockTime);

        // Should be able to withdraw
        vault.withdraw(vaultId);

        vm.stopPrank();
    }

    function testWithdrawWithExactGoalAmount() public {
        vm.startPrank(user1);

        uint256 goalAmount = 1 ether;
        uint256 vaultId = vault.createVault(goalAmount, 0, "Goal Test");

        // Deposit slightly more due to fees
        vault.deposit{value: 1.01 ether}(vaultId);

        (, uint256 balance, , , , ,,) = vault.getVaultDetails(vaultId);

        // Verify we can withdraw when goal is met
        if (balance >= goalAmount) {
            vault.withdraw(vaultId);
        }

        vm.stopPrank();
    }

    function testCannotTransferOwnershipToZeroAddress() public {
        vm.prank(owner);

        vm.expectRevert(SavingsVault.InvalidParameters.selector);
        vault.transferOwnership(address(0));
    }

    function testOwnershipTransferEmitsEvent() public {
        vm.prank(owner);

        address newOwner = address(100);

        vm.expectEmit(true, true, false, false);
        emit OwnershipTransferred(owner, newOwner);

        vault.transferOwnership(newOwner);
    }

    function testNewOwnerCanCollectFees() public {
        // Generate some fees
        vm.startPrank(user1);
        uint256 vaultId = vault.createVault(0, 0, "Test");
        vault.deposit{value: 1 ether}(vaultId);
        vm.stopPrank();

        // Transfer ownership
        address newOwner = address(100);
        vm.prank(owner);
        vault.transferOwnership(newOwner);

        // New owner collects fees
        uint256 feesCollected = vault.totalFeesCollected();
        vm.deal(newOwner, feesCollected + 1 ether); // Ensure newOwner has enough Ether for the transaction and to collect fees
        uint256 initialNewOwnerBalance = newOwner.balance; // Capture balance before collection

        vm.prank(newOwner);
        vault.collectFees();

        assertEq(vault.totalFeesCollected(), 0, "Fees should be collected");
        assertEq(newOwner.balance, initialNewOwnerBalance + feesCollected, "New owner should receive fees");
    }

    function testMetadataCanBeUpdatedMultipleTimes() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createVault(0, 0, "Original");

        vault.setVaultMetadata(vaultId, "Updated 1");
        (, , , , , , string memory meta1,) = vault.getVaultDetails(vaultId);
        assertEq(meta1, "Updated 1");

        vault.setVaultMetadata(vaultId, "Updated 2");
        (, , , , , , string memory meta2,) = vault.getVaultDetails(vaultId);
        assertEq(meta2, "Updated 2");

        vm.stopPrank();
    }

    function testVaultCreatedAtTimestampIsAccurate() public {
        uint256 beforeCreate = block.timestamp;

        vm.prank(user1);
        uint256 vaultId = vault.createVault(0, 0, "Time Test");

        (, , , , , uint256 createdAt,,) = vault.getVaultDetails(vaultId);

        assertEq(createdAt, beforeCreate, "Created timestamp should match block timestamp");
    }

    function testCanWithdrawReturnsFalseWhenLocked() public {
        vm.startPrank(user1);

        uint256 unlockTime = block.timestamp + 30 days;
        uint256 vaultId = vault.createVault(0, unlockTime, "Locked");
        vault.deposit{value: 1 ether}(vaultId);

        (, , , , , , , bool canWithdraw) = vault.getVaultDetails(vaultId);

        assertFalse(canWithdraw, "Should not be able to withdraw while locked");

        vm.stopPrank();
    }

    function testGetTotalVaults() public {
        assertEq(vault.getTotalVaults(), 0, "Should start at 0");

        vm.prank(user1);
        vault.createVault(0, 0, "Vault 1");
        assertEq(vault.getTotalVaults(), 1);

        vm.prank(user2);
        vault.createVault(0, 0, "Vault 2");
        assertEq(vault.getTotalVaults(), 2);
    }
}
