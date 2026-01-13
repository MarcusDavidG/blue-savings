// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./interfaces/IAutomation.sol";
import "./libraries/SafeERC20.sol";
import "./RecurringDepositStorage.sol";
import "./RecurringDepositEvents.sol";
import "./RecurringDepositErrors.sol";

/**
 * @title RecurringDeposit
 * @notice Automated recurring deposits for savings vaults
 * @dev Chainlink Automation compatible for scheduled execution
 */
contract RecurringDeposit is 
    RecurringDepositStorage, 
    RecurringDepositEvents, 
    RecurringDepositErrors,
    IAutomation 
{
    using SafeERC20 for IERC20;

    /// @notice Maximum schedules per user
    uint256 public constant MAX_SCHEDULES_PER_USER = 10;

    /// @notice Target vault contract address
    address public immutable vaultContract;

    /// @notice Contract owner
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyScheduleOwner(uint256 scheduleId) {
        if (schedules[scheduleId].owner != msg.sender) revert NotScheduleOwner();
        _;
    }

    modifier scheduleExists(uint256 scheduleId) {
        if (schedules[scheduleId].owner == address(0)) revert ScheduleNotFound(scheduleId);
        _;
    }

    constructor(address _vaultContract) {
        vaultContract = _vaultContract;
        owner = msg.sender;
    }

    /// @notice Create a new recurring deposit schedule
    function createSchedule(
        uint256 vaultId,
        address token,
        uint256 amount,
        Frequency frequency,
        uint256 totalExecutions,
        uint256 startTime
    ) external returns (uint256 scheduleId) {
        if (amount == 0) revert InvalidScheduleParams();
        if (totalExecutions == 0) revert ZeroExecutions();
        if (userSchedules[msg.sender].length >= MAX_SCHEDULES_PER_USER) {
            revert MaxSchedulesExceeded(MAX_SCHEDULES_PER_USER);
        }

        uint256 nextExec = startTime > block.timestamp ? startTime : block.timestamp;

        scheduleId = scheduleCounter++;

        schedules[scheduleId] = Schedule({
            owner: msg.sender,
            vaultId: vaultId,
            token: token,
            amount: amount,
            frequency: frequency,
            nextExecution: nextExec,
            totalExecutions: totalExecutions,
            executedCount: 0,
            status: ScheduleStatus.Active,
            createdAt: block.timestamp
        });

        userSchedules[msg.sender].push(scheduleId);
        vaultSchedules[vaultId].push(scheduleId);

        emit ScheduleCreated(scheduleId, msg.sender, vaultId, token, amount, frequency);
    }

    /// @notice Pause a schedule
    function pauseSchedule(uint256 scheduleId) 
        external 
        scheduleExists(scheduleId) 
        onlyScheduleOwner(scheduleId) 
    {
        Schedule storage schedule = schedules[scheduleId];
        if (schedule.status != ScheduleStatus.Active) revert ScheduleNotActive(scheduleId);

        schedule.status = ScheduleStatus.Paused;
        emit SchedulePaused(scheduleId);
    }

    /// @notice Resume a paused schedule
    function resumeSchedule(uint256 scheduleId) 
        external 
        scheduleExists(scheduleId) 
        onlyScheduleOwner(scheduleId) 
    {
        Schedule storage schedule = schedules[scheduleId];
        if (schedule.status != ScheduleStatus.Paused) revert ScheduleNotPaused(scheduleId);

        schedule.status = ScheduleStatus.Active;
        schedule.nextExecution = block.timestamp;
        emit ScheduleResumed(scheduleId);
    }

    /// @notice Cancel a schedule
    function cancelSchedule(uint256 scheduleId) 
        external 
        scheduleExists(scheduleId) 
        onlyScheduleOwner(scheduleId) 
    {
        schedules[scheduleId].status = ScheduleStatus.Cancelled;
        emit ScheduleCancelled(scheduleId);
    }

    /// @notice Check if any schedules need execution (Chainlink Automation)
    function checkUpkeep(bytes calldata) 
        external 
        view 
        override 
        returns (bool upkeepNeeded, bytes memory performData) 
    {
        for (uint256 i = 0; i < scheduleCounter; i++) {
            Schedule memory schedule = schedules[i];
            if (_isExecutable(schedule)) {
                return (true, abi.encode(i));
            }
        }
        return (false, "");
    }

    /// @notice Execute a due schedule (Chainlink Automation)
    function performUpkeep(bytes calldata performData) external override {
        uint256 scheduleId = abi.decode(performData, (uint256));
        executeSchedule(scheduleId);
    }

    /// @notice Manually execute a schedule
    function executeSchedule(uint256 scheduleId) public scheduleExists(scheduleId) {
        Schedule storage schedule = schedules[scheduleId];
        
        if (schedule.status != ScheduleStatus.Active) revert ScheduleNotActive(scheduleId);
        if (block.timestamp < schedule.nextExecution) {
            revert ExecutionNotDue(scheduleId, schedule.nextExecution);
        }

        // Transfer tokens from owner to this contract
        IERC20(schedule.token).safeTransferFrom(
            schedule.owner, 
            address(this), 
            schedule.amount
        );

        // Approve and deposit to vault
        IERC20(schedule.token).approve(vaultContract, schedule.amount);
        
        // Call depositToken on vault (assuming interface)
        (bool success,) = vaultContract.call(
            abi.encodeWithSignature(
                "depositToken(uint256,address,uint256)",
                schedule.vaultId,
                schedule.token,
                schedule.amount
            )
        );
        require(success, "Deposit failed");

        schedule.executedCount++;
        schedule.nextExecution = block.timestamp + _getInterval(schedule.frequency);

        emit ScheduledDepositExecuted(
            scheduleId, 
            schedule.vaultId, 
            schedule.amount, 
            schedule.executedCount
        );

        // Check if completed
        if (schedule.executedCount >= schedule.totalExecutions) {
            schedule.status = ScheduleStatus.Completed;
            emit ScheduleCompleted(scheduleId, schedule.executedCount);
        }
    }

    /// @notice Check if schedule is ready for execution
    function _isExecutable(Schedule memory schedule) internal view returns (bool) {
        return schedule.status == ScheduleStatus.Active && 
               block.timestamp >= schedule.nextExecution &&
               schedule.executedCount < schedule.totalExecutions;
    }
}
