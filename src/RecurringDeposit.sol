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
 * @notice Manages automated recurring deposits for savings vaults using Chainlink Automation.
 * @dev This contract allows users to create, pause, resume, and cancel recurring deposit
 * schedules. It is designed to be compatible with Chainlink Automation for scheduled
 * execution of these deposits.
 */
contract RecurringDeposit is 
    RecurringDepositStorage, 
    RecurringDepositEvents, 
    RecurringDepositErrors,
    IAutomation 
{
    using SafeERC20 for IERC20;

    /// @notice The maximum number of active or paused schedules a user can have.
    uint256 public constant MAX_SCHEDULES_PER_USER = 10;

    /// @notice The address of the target vault contract where funds will be deposited.
    address public immutable vaultContract;

    /// @notice The address of the contract owner, with privileges to manage the contract.
    address public owner;

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @dev Throws if the caller is not the owner of the specified schedule.
     * @param scheduleId The ID of the schedule to check ownership of.
     */
    modifier onlyScheduleOwner(uint256 scheduleId) {
        if (schedules[scheduleId].owner != msg.sender) revert NotScheduleOwner();
        _;
    }

    /**
     * @dev Throws if a schedule with the given ID does not exist.
     * @param scheduleId The ID of the schedule to check.
     */
    modifier scheduleExists(uint256 scheduleId) {
        if (schedules[scheduleId].owner == address(0)) revert ScheduleNotFound(scheduleId);
        _;
    }

    /**
     * @notice Sets the address of the vault contract and the contract owner.
     * @param _vaultContract The address of the vault contract.
     */
    constructor(address _vaultContract) {
        vaultContract = _vaultContract;
        owner = msg.sender;
    }

    /**
     * @notice Creates a new recurring deposit schedule.
     * @param vaultId The ID of the vault to deposit into.
     * @param token The address of the ERC20 token for the deposit.
     * @param amount The amount of tokens to be deposited in each execution.
     * @param frequency The frequency of the recurring deposit (e.g., daily, weekly).
     * @param totalExecutions The total number of times the deposit should be executed.
     * @param startTime The timestamp when the first deposit should be executed.
     * @return scheduleId The ID of the newly created schedule.
     */
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

    /**
     * @notice Pauses an active recurring deposit schedule.
     * @dev Only the owner of the schedule can pause it.
     * @param scheduleId The ID of the schedule to pause.
     */
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

    /**
     * @notice Resumes a paused recurring deposit schedule.
     * @dev Only the owner of the schedule can resume it. The next execution is set to the current time.
     * @param scheduleId The ID of the schedule to resume.
     */
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

    /**
     * @notice Cancels a recurring deposit schedule.
     * @dev A canceled schedule cannot be resumed or executed.
     * @param scheduleId The ID of the schedule to cancel.
     */
    function cancelSchedule(uint256 scheduleId) 
        external 
        scheduleExists(scheduleId) 
        onlyScheduleOwner(scheduleId) 
    {
        schedules[scheduleId].status = ScheduleStatus.Cancelled;
        emit ScheduleCancelled(scheduleId);
    }

    /**
     * @notice Called by Chainlink Automation to check if any schedules need execution.
     * @dev This function iterates through all schedules and returns `true` if any are ready to be executed.
     * @param checkData Arbitrary data sent by the Chainlink node, not used here.
     * @return upkeepNeeded A boolean indicating if an update is needed.
     * @return performData The data to be passed to `performUpkeep`, encoding the schedule ID.
     */
    function checkUpkeep(bytes calldata checkData) 
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

    /**
     * @notice Called by Chainlink Automation to execute a due schedule.
     * @dev This function decodes the schedule ID from `performData` and calls `executeSchedule`.
     * @param performData The data returned from `checkUpkeep`, containing the schedule ID.
     */
    function performUpkeep(bytes calldata performData) external override {
        uint256 scheduleId = abi.decode(performData, (uint256));
        executeSchedule(scheduleId);
    }

    /**
     * @notice Manually executes a recurring deposit schedule.
     * @dev This can be called by anyone, but it will only execute if the schedule is due.
     * It transfers tokens from the schedule owner, approves the vault, and deposits the funds.
     * @param scheduleId The ID of the schedule to execute.
     */
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

    /**
     * @notice Checks if a schedule is ready for execution.
     * @dev A schedule is executable if it's active, the current time is past its next execution time,
     * and it has not yet completed all its scheduled executions.
     * @param schedule The schedule to check.
     * @return A boolean indicating if the schedule is executable.
     */
    function _isExecutable(Schedule memory schedule) internal view returns (bool) {
        return schedule.status == ScheduleStatus.Active && 
               block.timestamp >= schedule.nextExecution &&
               schedule.executedCount < schedule.totalExecutions;
    }

    /**
     * @notice Estimates gas required for executing a schedule
     * @dev Used by automation nodes to determine gas limits
     * @return gasEstimate Estimated gas for executeSchedule
     */
    function estimateExecutionGas() external pure returns (uint256 gasEstimate) {
        // Base gas: ~21000 for transaction
        // Token transfer: ~65000
        // Approval: ~45000
        // Vault deposit: ~100000
        // State updates: ~20000
        return 300000;
    }

    /**
     * @notice Get count of pending executions across all active schedules
     * @return count Number of schedules ready to execute
     */
    function getPendingExecutionCount() external view returns (uint256 count) {
        for (uint256 i = 0; i < scheduleCounter; i++) {
            if (_isExecutable(schedules[i])) {
                count++;
            }
        }
    }
}
