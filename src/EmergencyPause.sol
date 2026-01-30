// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title EmergencyPause
 * @dev Emergency pause functionality for critical contract operations
 */
contract EmergencyPause {
    bool private _paused;
    address public owner;
    address public emergencyOperator;
    
    uint256 public pausedAt;
    uint256 public constant MAX_PAUSE_DURATION = 7 days;
    
    event Paused(address account, uint256 timestamp);
    event Unpaused(address account, uint256 timestamp);
    event EmergencyOperatorChanged(address indexed previousOperator, address indexed newOperator);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    modifier onlyEmergencyOperator() {
        require(msg.sender == emergencyOperator || msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }
    
    modifier whenPaused() {
        require(_paused, "Contract is not paused");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        emergencyOperator = msg.sender;
    }
    
    function paused() public view returns (bool) {
        return _paused;
    }
    
    function pause() external onlyEmergencyOperator {
        require(!_paused, "Already paused");
        _paused = true;
        pausedAt = block.timestamp;
        emit Paused(msg.sender, block.timestamp);
    }
    
    function unpause() external onlyOwner {
        require(_paused, "Not paused");
        _paused = false;
        pausedAt = 0;
        emit Unpaused(msg.sender, block.timestamp);
    }
    
    function emergencyUnpause() external {
        require(_paused, "Not paused");
        require(block.timestamp >= pausedAt + MAX_PAUSE_DURATION, "Pause duration not exceeded");
        
        _paused = false;
        pausedAt = 0;
        emit Unpaused(msg.sender, block.timestamp);
    }
    
    function setEmergencyOperator(address newOperator) external onlyOwner {
        require(newOperator != address(0), "Invalid operator");
        address previousOperator = emergencyOperator;
        emergencyOperator = newOperator;
        emit EmergencyOperatorChanged(previousOperator, newOperator);
    }
    
    function getRemainingPauseTime() external view returns (uint256) {
        if (!_paused) return 0;
        
        uint256 elapsed = block.timestamp - pausedAt;
        if (elapsed >= MAX_PAUSE_DURATION) return 0;
        
        return MAX_PAUSE_DURATION - elapsed;
    }
}
