// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title EmergencyStop
 * @notice Emergency circuit breaker for protocol
 */
contract EmergencyStop {
    address public guardian;
    address public owner;

    bool public stopped;
    uint256 public stopTimestamp;
    uint256 public constant MAX_STOP_DURATION = 7 days;

    event EmergencyStopped(address indexed by, string reason);
    event EmergencyResumed(address indexed by);
    event GuardianUpdated(address indexed newGuardian);

    error NotGuardianOrOwner();
    error AlreadyStopped();
    error NotStopped();
    error StopExpired();

    modifier whenNotStopped() {
        require(!stopped || block.timestamp > stopTimestamp + MAX_STOP_DURATION, "Protocol stopped");
        _;
    }

    modifier onlyGuardianOrOwner() {
        if (msg.sender != guardian && msg.sender != owner) revert NotGuardianOrOwner();
        _;
    }

    constructor() {
        owner = msg.sender;
        guardian = msg.sender;
    }

    function emergencyStop(string calldata reason) external onlyGuardianOrOwner {
        if (stopped) revert AlreadyStopped();
        stopped = true;
        stopTimestamp = block.timestamp;
        emit EmergencyStopped(msg.sender, reason);
    }

    function resume() external {
        require(msg.sender == owner, "Only owner");
        if (!stopped) revert NotStopped();
        stopped = false;
        emit EmergencyResumed(msg.sender);
    }

    function setGuardian(address _guardian) external {
        require(msg.sender == owner, "Only owner");
        guardian = _guardian;
        emit GuardianUpdated(_guardian);
    }

    function isStopped() external view returns (bool) {
        if (!stopped) return false;
        if (block.timestamp > stopTimestamp + MAX_STOP_DURATION) return false;
        return true;
    }
}
