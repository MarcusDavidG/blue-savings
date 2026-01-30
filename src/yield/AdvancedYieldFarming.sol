// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title AdvancedYieldFarming
 * @dev Multi-protocol yield farming with auto-compounding
 */
contract AdvancedYieldFarming is Ownable, ReentrancyGuard {
    struct YieldStrategy {
        address protocol;
        uint256 apy;
        uint256 tvl;
        uint256 riskScore;
        bool isActive;
        uint256 lastUpdated;
    }
    
    struct FarmPosition {
        uint256 strategyId;
        uint256 principal;
        uint256 rewards;
        uint256 lastCompound;
        uint256 startTime;
    }
    
    mapping(uint256 => YieldStrategy) public strategies;
    mapping(uint256 => mapping(address => FarmPosition)) public positions;
    mapping(address => uint256[]) public userStrategies;
    
    uint256 public strategyCounter;
    uint256 public totalValueLocked;
    uint256 public constant COMPOUND_THRESHOLD = 0.01 ether;
    uint256 public constant AUTO_COMPOUND_INTERVAL = 1 days;
    
    event StrategyAdded(uint256 indexed strategyId, address protocol, uint256 apy);
    event PositionOpened(address indexed user, uint256 indexed strategyId, uint256 amount);
    event RewardsCompounded(address indexed user, uint256 indexed strategyId, uint256 rewards);
    event PositionClosed(address indexed user, uint256 indexed strategyId, uint256 amount);
    event StrategyUpdated(uint256 indexed strategyId, uint256 newApy, uint256 newRiskScore);
    
    constructor() Ownable(msg.sender) {}
    
    function addStrategy(
        address protocol,
        uint256 apy,
        uint256 riskScore
    ) external onlyOwner returns (uint256) {
        require(protocol != address(0), "Invalid protocol");
        require(apy > 0, "APY must be positive");
        require(riskScore <= 100, "Risk score too high");
        
        uint256 strategyId = ++strategyCounter;
        strategies[strategyId] = YieldStrategy({
            protocol: protocol,
            apy: apy,
            tvl: 0,
            riskScore: riskScore,
            isActive: true,
            lastUpdated: block.timestamp
        });
        
        emit StrategyAdded(strategyId, protocol, apy);
        return strategyId;
    }
    
    function openPosition(uint256 strategyId) external payable nonReentrant {
        require(msg.value > 0, "Amount must be positive");
        YieldStrategy storage strategy = strategies[strategyId];
        require(strategy.isActive, "Strategy not active");
        
        FarmPosition storage position = positions[strategyId][msg.sender];
        
        if (position.principal == 0) {
            userStrategies[msg.sender].push(strategyId);
            position.startTime = block.timestamp;
        }
        
        position.principal += msg.value;
        position.lastCompound = block.timestamp;
        strategy.tvl += msg.value;
        totalValueLocked += msg.value;
        
        emit PositionOpened(msg.sender, strategyId, msg.value);
    }
    
    function compoundRewards(uint256 strategyId) external nonReentrant {
        FarmPosition storage position = positions[strategyId][msg.sender];
        require(position.principal > 0, "No position");
        
        uint256 rewards = calculateRewards(strategyId, msg.sender);
        require(rewards >= COMPOUND_THRESHOLD, "Rewards below threshold");
        
        position.rewards += rewards;
        position.principal += rewards;
        position.lastCompound = block.timestamp;
        
        strategies[strategyId].tvl += rewards;
        totalValueLocked += rewards;
        
        emit RewardsCompounded(msg.sender, strategyId, rewards);
    }
    
    function closePosition(uint256 strategyId) external nonReentrant {
        FarmPosition storage position = positions[strategyId][msg.sender];
        require(position.principal > 0, "No position");
        
        uint256 rewards = calculateRewards(strategyId, msg.sender);
        uint256 totalAmount = position.principal + rewards;
        
        // Update strategy TVL
        strategies[strategyId].tvl -= position.principal;
        totalValueLocked -= position.principal;
        
        // Clear position
        delete positions[strategyId][msg.sender];
        
        // Remove from user strategies
        _removeUserStrategy(msg.sender, strategyId);
        
        payable(msg.sender).transfer(totalAmount);
        emit PositionClosed(msg.sender, strategyId, totalAmount);
    }
    
    function calculateRewards(uint256 strategyId, address user) public view returns (uint256) {
        FarmPosition memory position = positions[strategyId][user];
        if (position.principal == 0) return 0;
        
        YieldStrategy memory strategy = strategies[strategyId];
        uint256 timeElapsed = block.timestamp - position.lastCompound;
        
        return (position.principal * strategy.apy * timeElapsed) / (10000 * 365 days);
    }
    
    function updateStrategy(
        uint256 strategyId,
        uint256 newApy,
        uint256 newRiskScore
    ) external onlyOwner {
        YieldStrategy storage strategy = strategies[strategyId];
        require(strategy.protocol != address(0), "Strategy not found");
        
        strategy.apy = newApy;
        strategy.riskScore = newRiskScore;
        strategy.lastUpdated = block.timestamp;
        
        emit StrategyUpdated(strategyId, newApy, newRiskScore);
    }
    
    function getBestStrategy() external view returns (uint256 bestId, uint256 bestApy) {
        for (uint256 i = 1; i <= strategyCounter; i++) {
            YieldStrategy memory strategy = strategies[i];
            if (strategy.isActive && strategy.apy > bestApy) {
                bestId = i;
                bestApy = strategy.apy;
            }
        }
    }
    
    function getUserPositions(address user) external view returns (uint256[] memory) {
        return userStrategies[user];
    }
    
    function _removeUserStrategy(address user, uint256 strategyId) internal {
        uint256[] storage userStrats = userStrategies[user];
        for (uint256 i = 0; i < userStrats.length; i++) {
            if (userStrats[i] == strategyId) {
                userStrats[i] = userStrats[userStrats.length - 1];
                userStrats.pop();
                break;
            }
        }
    }
}
