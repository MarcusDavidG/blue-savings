// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VaultAnalytics.sol";
import "../src/interfaces/IVaultMetrics.sol";

contract VaultAnalyticsTest is Test {
    VaultAnalytics public analytics;
    address public mockVault;
    address public user1;
    address public user2;
    
    event MetricsUpdated(uint256 indexed vaultId, IVaultMetrics.VaultMetrics metrics);
    
    function setUp() public {
        mockVault = makeAddr("mockVault");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        analytics = new VaultAnalytics(mockVault);
    }
    
    function testInitializeVault() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        IVaultMetrics.VaultMetrics memory metrics = analytics.getVaultMetrics(1);
        assertEq(metrics.creationTimestamp, block.timestamp);
        assertEq(metrics.lastActivityTimestamp, block.timestamp);
        assertTrue(metrics.isActive);
        
        IVaultMetrics.GlobalMetrics memory globalMetrics = analytics.getGlobalMetrics();
        assertEq(globalMetrics.totalVaults, 1);
        assertEq(globalMetrics.activeVaults, 1);
    }
    
    function testRecordDeposit() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        IVaultMetrics.VaultMetrics memory metrics = analytics.getVaultMetrics(1);
        assertEq(metrics.totalDeposits, 1 ether);
        assertEq(metrics.depositCount, 1);
        assertEq(metrics.totalFeesPaid, 0.005 ether);
        assertEq(metrics.averageDepositAmount, 1 ether);
        
        IVaultMetrics.GlobalMetrics memory globalMetrics = analytics.getGlobalMetrics();
        assertEq(globalMetrics.totalValueLocked, 1 ether);
        assertEq(globalMetrics.totalFeesCollected, 0.005 ether);
    }
    
    function testRecordWithdrawal() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        vm.warp(block.timestamp + 30 days);
        
        vm.prank(mockVault);
        analytics.recordWithdrawal(1, 0.5 ether);
        
        IVaultMetrics.VaultMetrics memory metrics = analytics.getVaultMetrics(1);
        assertEq(metrics.totalWithdrawals, 0.5 ether);
        assertEq(metrics.withdrawalCount, 1);
        assertEq(metrics.averageHoldingPeriod, 30 days);
        
        IVaultMetrics.GlobalMetrics memory globalMetrics = analytics.getGlobalMetrics();
        assertEq(globalMetrics.totalValueLocked, 0.5 ether);
    }
    
    function testMultipleDeposits() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 2 ether, 0.01 ether);
        
        IVaultMetrics.VaultMetrics memory metrics = analytics.getVaultMetrics(1);
        assertEq(metrics.totalDeposits, 3 ether);
        assertEq(metrics.depositCount, 2);
        assertEq(metrics.totalFeesPaid, 0.015 ether);
        assertEq(metrics.averageDepositAmount, 1.5 ether);
    }
    
    function testGetUserVaults() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.prank(mockVault);
        analytics.initializeVault(2, user1);
        
        vm.prank(mockVault);
        analytics.initializeVault(3, user2);
        
        uint256[] memory user1Vaults = analytics.getUserVaults(user1);
        assertEq(user1Vaults.length, 2);
        assertEq(user1Vaults[0], 1);
        assertEq(user1Vaults[1], 2);
        
        uint256[] memory user2Vaults = analytics.getUserVaults(user2);
        assertEq(user2Vaults.length, 1);
        assertEq(user2Vaults[0], 3);
    }
    
    function testGetTopPerformingVaults() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        vm.prank(mockVault);
        analytics.initializeVault(2, user2);
        vm.prank(mockVault);
        analytics.recordDeposit(2, 2 ether, 0.01 ether);
        
        uint256[] memory topVaults = analytics.getTopPerformingVaults(2);
        assertEq(topVaults.length, 2);
        assertEq(topVaults[0], 1);
        assertEq(topVaults[1], 2);
    }
    
    function testGetVaultPerformanceScore() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        vm.prank(mockVault);
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        uint256 score = analytics.getVaultPerformanceScore(1);
        assertGt(score, 0);
        
        // Score should be based on consistency (deposit count) and size
        uint256 expectedScore = 2 * 10 + (2 ether / 1e15);
        assertEq(score, expectedScore);
    }
    
    function testOnlyVaultModifier() public {
        vm.expectRevert("Only vault can call");
        analytics.initializeVault(1, user1);
        
        vm.expectRevert("Only vault can call");
        analytics.recordDeposit(1, 1 ether, 0.005 ether);
        
        vm.expectRevert("Only vault can call");
        analytics.recordWithdrawal(1, 0.5 ether);
        
        vm.expectRevert("Only vault can call");
        analytics.updateVaultMetrics(1);
    }
    
    function testEventEmission() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        vm.expectEmit(true, false, false, true);
        emit MetricsUpdated(1, analytics.getVaultMetrics(1));
        
        vm.prank(mockVault);
        analytics.updateVaultMetrics(1);
    }
    
    function testZeroDepositHandling() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        uint256 score = analytics.getVaultPerformanceScore(1);
        assertEq(score, 0); // No deposits, score should be 0
    }
    
    function testInactiveVaultHandling() public {
        vm.prank(mockVault);
        analytics.initializeVault(1, user1);
        
        // Vault is active but has no deposits
        uint256[] memory topVaults = analytics.getTopPerformingVaults(1);
        assertEq(topVaults[0], 0); // Should return 0 for inactive vault
    }
}
