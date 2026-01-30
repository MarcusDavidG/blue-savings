// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title EmergencyPause
 * @dev Circuit breaker pattern for emergency protocol shutdown
 */
contract EmergencyPause is Ownable, ReentrancyGuard {
    bool public isPaused;
    bool public isDepositsPaused;
    bool public isWithdrawalsPaused;
    
    mapping(address => bool) public emergencyOperators;
    
    uint256 public pauseStartTime;
    uint256 public constant MAX_PAUSE_DURATION = 7 days;
    
    event EmergencyPaused(address indexed operator, string reason);
    event EmergencyUnpaused(address indexed operator);
    event DepositsPaused(address indexed operator);
    event WithdrawalsPaused(address indexed operator);
    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    
    modifier whenNotPaused() {
        require(!isPaused, "Contract is paused");
        _;
    }
    
    modifier whenDepositsNotPaused() {
        require(!isDepositsPaused, "Deposits are paused");
        _;
    }
    
    modifier whenWithdrawalsNotPaused() {
        require(!isWithdrawalsPaused, "Withdrawals are paused");
        _;
    }
    
    modifier onlyEmergencyOperator() {
        require(emergencyOperators[msg.sender] || msg.sender == owner(), "Not authorized");
        _;
    }
    
    constructor() Ownable(msg.sender) {}
    
    function addEmergencyOperator(address operator) external onlyOwner {
        emergencyOperators[operator] = true;
        emit OperatorAdded(operator);
    }
    
    function removeEmergencyOperator(address operator) external onlyOwner {
        emergencyOperators[operator] = false;
        emit OperatorRemoved(operator);
    }
    
    function emergencyPause(string calldata reason) external onlyEmergencyOperator {
        isPaused = true;
        pauseStartTime = block.timestamp;
        emit EmergencyPaused(msg.sender, reason);
    }
    
    function emergencyUnpause() external onlyOwner {
        isPaused = false;
        pauseStartTime = 0;
        emit EmergencyUnpaused(msg.sender);
    }
    
    function pauseDeposits() external onlyEmergencyOperator {
        isDepositsPaused = true;
        emit DepositsPaused(msg.sender);
    }
    
    function unpauseDeposits() external onlyOwner {
        isDepositsPaused = false;
    }
    
    function pauseWithdrawals() external onlyEmergencyOperator {
        isWithdrawalsPaused = true;
        emit WithdrawalsPaused(msg.sender);
    }
    
    function unpauseWithdrawals() external onlyOwner {
        isWithdrawalsPaused = false;
    }
    
    function forceUnpause() external onlyOwner {
        require(block.timestamp >= pauseStartTime + MAX_PAUSE_DURATION, "Pause duration not exceeded");
        isPaused = false;
        pauseStartTime = 0;
        emit EmergencyUnpaused(msg.sender);
    }
}
