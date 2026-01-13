// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/RecurringDeposit.sol";
import "../src/TokenSavingsVault.sol";
import "../src/mocks/MockERC20.sol";

contract RecurringDepositTest is Test {
    RecurringDeposit public recurring;
    TokenSavingsVault public vault;
    MockERC20 public usdc;

    address public user1;

    function setUp() public {
        user1 = makeAddr("user1");

        vault = new TokenSavingsVault();
        recurring = new RecurringDeposit(address(vault));
        usdc = new MockERC20("USD Coin", "USDC", 6);

        vault.whitelistToken(address(usdc));
        usdc.mint(user1, 100000e6);
    }

    function test_CreateSchedule() public {
        vm.startPrank(user1);

        // Create vault first
        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test Vault");

        // Create recurring schedule
        uint256 scheduleId = recurring.createSchedule(
            vaultId,
            address(usdc),
            100e6, // 100 USDC per execution
            RecurringDepositTypes.Frequency.Weekly,
            12, // 12 executions (3 months)
            block.timestamp
        );

        vm.stopPrank();

        assertEq(scheduleId, 0);

        RecurringDepositTypes.Schedule memory schedule = recurring.getSchedule(scheduleId);
        assertEq(schedule.owner, user1);
        assertEq(schedule.vaultId, vaultId);
        assertEq(schedule.amount, 100e6);
        assertEq(schedule.totalExecutions, 12);
    }

    function test_ExecuteSchedule() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");
        uint256 scheduleId = recurring.createSchedule(
            vaultId,
            address(usdc),
            100e6,
            RecurringDepositTypes.Frequency.Daily,
            5,
            block.timestamp
        );

        // Approve recurring contract to spend tokens
        usdc.approve(address(recurring), type(uint256).max);

        // Execute
        recurring.executeSchedule(scheduleId);

        vm.stopPrank();

        RecurringDepositTypes.Schedule memory schedule = recurring.getSchedule(scheduleId);
        assertEq(schedule.executedCount, 1);
    }

    function test_PauseAndResumeSchedule() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");
        uint256 scheduleId = recurring.createSchedule(
            vaultId,
            address(usdc),
            100e6,
            RecurringDepositTypes.Frequency.Daily,
            5,
            block.timestamp
        );

        recurring.pauseSchedule(scheduleId);
        
        RecurringDepositTypes.Schedule memory schedule = recurring.getSchedule(scheduleId);
        assertEq(uint256(schedule.status), uint256(RecurringDepositTypes.ScheduleStatus.Paused));

        recurring.resumeSchedule(scheduleId);
        
        schedule = recurring.getSchedule(scheduleId);
        assertEq(uint256(schedule.status), uint256(RecurringDepositTypes.ScheduleStatus.Active));

        vm.stopPrank();
    }

    function test_CancelSchedule() public {
        vm.startPrank(user1);

        uint256 vaultId = vault.createTokenVault(address(0), 0, 0, "Test");
        uint256 scheduleId = recurring.createSchedule(
            vaultId,
            address(usdc),
            100e6,
            RecurringDepositTypes.Frequency.Daily,
            5,
            block.timestamp
        );

        recurring.cancelSchedule(scheduleId);

        vm.stopPrank();

        RecurringDepositTypes.Schedule memory schedule = recurring.getSchedule(scheduleId);
        assertEq(uint256(schedule.status), uint256(RecurringDepositTypes.ScheduleStatus.Cancelled));
    }
}
