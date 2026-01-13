// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultNotifier
 * @notice Event emitter for off-chain notification systems
 */
contract VaultNotifier {
    event GoalReached(uint256 indexed vaultId, address indexed owner, uint256 goalAmount);
    event UnlockApproaching(uint256 indexed vaultId, address indexed owner, uint256 unlockTime);
    event LargeDeposit(uint256 indexed vaultId, address indexed depositor, uint256 amount);
    event MilestoneReached(uint256 indexed vaultId, address indexed owner, uint256 milestone);
    event ScheduleExecuted(uint256 indexed scheduleId, address indexed owner);
    event ReferralEarned(address indexed referrer, address indexed referee, uint256 reward);

    address public vault;
    address public owner;

    modifier onlyVault() {
        require(msg.sender == vault, "Not vault");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setVault(address _vault) external {
        require(msg.sender == owner, "Not owner");
        vault = _vault;
    }

    function notifyGoalReached(uint256 vaultId, address vaultOwner, uint256 goalAmount) external onlyVault {
        emit GoalReached(vaultId, vaultOwner, goalAmount);
    }

    function notifyUnlockApproaching(uint256 vaultId, address vaultOwner, uint256 unlockTime) external onlyVault {
        emit UnlockApproaching(vaultId, vaultOwner, unlockTime);
    }

    function notifyLargeDeposit(uint256 vaultId, address depositor, uint256 amount) external onlyVault {
        emit LargeDeposit(vaultId, depositor, amount);
    }

    function notifyMilestone(uint256 vaultId, address vaultOwner, uint256 milestone) external onlyVault {
        emit MilestoneReached(vaultId, vaultOwner, milestone);
    }
}
