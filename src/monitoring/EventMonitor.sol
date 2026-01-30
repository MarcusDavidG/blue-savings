// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EventMonitor
 * @dev Comprehensive event monitoring and alerting system
 */
contract EventMonitor is Ownable {
    struct EventRule {
        uint256 id;
        string name;
        address contractAddress;
        bytes32 eventSignature;
        bool isActive;
        uint256 threshold;
        uint256 timeWindow;
        uint256 lastTriggered;
        uint256 triggerCount;
        AlertLevel alertLevel;
        string description;
    }
    
    struct Alert {
        uint256 id;
        uint256 ruleId;
        address contractAddress;
        bytes32 eventSignature;
        bytes eventData;
        uint256 timestamp;
        AlertLevel level;
        bool isResolved;
        string message;
    }
    
    enum AlertLevel { INFO, WARNING, CRITICAL, EMERGENCY }
    
    mapping(uint256 => EventRule) public eventRules;
    mapping(uint256 => Alert) public alerts;
    mapping(address => bool) public authorizedMonitors;
    mapping(bytes32 => uint256) public eventCounts;
    mapping(bytes32 => uint256) public lastEventTime;
    
    uint256 public ruleCounter;
    uint256 public alertCounter;
    uint256 public constant MAX_TIME_WINDOW = 24 hours;
    
    event RuleCreated(uint256 indexed ruleId, string name, address contractAddress);
    event AlertTriggered(uint256 indexed alertId, uint256 indexed ruleId, AlertLevel level);
    event AlertResolved(uint256 indexed alertId, address resolver);
    event MonitorAuthorized(address indexed monitor);
    event MonitorRevoked(address indexed monitor);
    event EventDetected(address indexed contractAddress, bytes32 indexed eventSignature, bytes data);
    
    modifier onlyAuthorizedMonitor() {
        require(authorizedMonitors[msg.sender] || msg.sender == owner(), "Not authorized monitor");
        _;
    }
    
    constructor() Ownable(msg.sender) {
        authorizedMonitors[msg.sender] = true;
    }
    
    function authorizeMonitor(address monitor) external onlyOwner {
        authorizedMonitors[monitor] = true;
        emit MonitorAuthorized(monitor);
    }
    
    function revokeMonitor(address monitor) external onlyOwner {
        authorizedMonitors[monitor] = false;
        emit MonitorRevoked(monitor);
    }
    
    function createEventRule(
        string calldata name,
        address contractAddress,
        bytes32 eventSignature,
        uint256 threshold,
        uint256 timeWindow,
        AlertLevel alertLevel,
        string calldata description
    ) external onlyAuthorizedMonitor returns (uint256) {
        require(contractAddress != address(0), "Invalid contract address");
        require(threshold > 0, "Threshold must be positive");
        require(timeWindow > 0 && timeWindow <= MAX_TIME_WINDOW, "Invalid time window");
        
        uint256 ruleId = ++ruleCounter;
        
        eventRules[ruleId] = EventRule({
            id: ruleId,
            name: name,
            contractAddress: contractAddress,
            eventSignature: eventSignature,
            isActive: true,
            threshold: threshold,
            timeWindow: timeWindow,
            lastTriggered: 0,
            triggerCount: 0,
            alertLevel: alertLevel,
            description: description
        });
        
        emit RuleCreated(ruleId, name, contractAddress);
        return ruleId;
    }
    
    function reportEvent(
        address contractAddress,
        bytes32 eventSignature,
        bytes calldata eventData
    ) external onlyAuthorizedMonitor {
        bytes32 eventKey = keccak256(abi.encodePacked(contractAddress, eventSignature));
        
        eventCounts[eventKey]++;
        lastEventTime[eventKey] = block.timestamp;
        
        emit EventDetected(contractAddress, eventSignature, eventData);
        
        // Check all rules for this event
        _checkEventRules(contractAddress, eventSignature, eventData);
    }
    
    function _checkEventRules(
        address contractAddress,
        bytes32 eventSignature,
        bytes calldata eventData
    ) internal {
        for (uint256 i = 1; i <= ruleCounter; i++) {
            EventRule storage rule = eventRules[i];
            
            if (!rule.isActive) continue;
            if (rule.contractAddress != contractAddress) continue;
            if (rule.eventSignature != eventSignature) continue;
            
            bytes32 eventKey = keccak256(abi.encodePacked(contractAddress, eventSignature));
            uint256 recentEvents = _getRecentEventCount(eventKey, rule.timeWindow);
            
            if (recentEvents >= rule.threshold) {
                _triggerAlert(rule, eventData);
            }
        }
    }
    
    function _getRecentEventCount(bytes32 eventKey, uint256 timeWindow) internal view returns (uint256) {
        // Simplified implementation - in practice, would need more sophisticated tracking
        if (block.timestamp - lastEventTime[eventKey] <= timeWindow) {
            return eventCounts[eventKey];
        }
        return 0;
    }
    
    function _triggerAlert(EventRule storage rule, bytes calldata eventData) internal {
        // Prevent spam alerts
        if (block.timestamp - rule.lastTriggered < 300) return; // 5 minute cooldown
        
        uint256 alertId = ++alertCounter;
        
        string memory message = string(abi.encodePacked(
            "Rule '", rule.name, "' triggered: ",
            "threshold of ", _uint2str(rule.threshold),
            " events exceeded in ", _uint2str(rule.timeWindow), " seconds"
        ));
        
        alerts[alertId] = Alert({
            id: alertId,
            ruleId: rule.id,
            contractAddress: rule.contractAddress,
            eventSignature: rule.eventSignature,
            eventData: eventData,
            timestamp: block.timestamp,
            level: rule.alertLevel,
            isResolved: false,
            message: message
        });
        
        rule.lastTriggered = block.timestamp;
        rule.triggerCount++;
        
        emit AlertTriggered(alertId, rule.id, rule.alertLevel);
    }
    
    function resolveAlert(uint256 alertId) external onlyAuthorizedMonitor {
        require(alertId > 0 && alertId <= alertCounter, "Invalid alert ID");
        Alert storage alert = alerts[alertId];
        require(!alert.isResolved, "Alert already resolved");
        
        alert.isResolved = true;
        emit AlertResolved(alertId, msg.sender);
    }
    
    function updateEventRule(
        uint256 ruleId,
        uint256 threshold,
        uint256 timeWindow,
        AlertLevel alertLevel,
        bool isActive
    ) external onlyAuthorizedMonitor {
        require(ruleId > 0 && ruleId <= ruleCounter, "Invalid rule ID");
        EventRule storage rule = eventRules[ruleId];
        
        rule.threshold = threshold;
        rule.timeWindow = timeWindow;
        rule.alertLevel = alertLevel;
        rule.isActive = isActive;
    }
    
    function getActiveAlerts() external view returns (Alert[] memory) {
        uint256 activeCount = 0;
        
        // Count active alerts
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (!alerts[i].isResolved) {
                activeCount++;
            }
        }
        
        Alert[] memory activeAlerts = new Alert[](activeCount);
        uint256 index = 0;
        
        // Populate active alerts
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (!alerts[i].isResolved) {
                activeAlerts[index] = alerts[i];
                index++;
            }
        }
        
        return activeAlerts;
    }
    
    function getEventRulesByContract(address contractAddress) external view returns (EventRule[] memory) {
        uint256 matchingCount = 0;
        
        // Count matching rules
        for (uint256 i = 1; i <= ruleCounter; i++) {
            if (eventRules[i].contractAddress == contractAddress) {
                matchingCount++;
            }
        }
        
        EventRule[] memory matchingRules = new EventRule[](matchingCount);
        uint256 index = 0;
        
        // Populate matching rules
        for (uint256 i = 1; i <= ruleCounter; i++) {
            if (eventRules[i].contractAddress == contractAddress) {
                matchingRules[index] = eventRules[i];
                index++;
            }
        }
        
        return matchingRules;
    }
    
    function getAlertsByLevel(AlertLevel level) external view returns (Alert[] memory) {
        uint256 matchingCount = 0;
        
        // Count matching alerts
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (alerts[i].level == level && !alerts[i].isResolved) {
                matchingCount++;
            }
        }
        
        Alert[] memory matchingAlerts = new Alert[](matchingCount);
        uint256 index = 0;
        
        // Populate matching alerts
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (alerts[i].level == level && !alerts[i].isResolved) {
                matchingAlerts[index] = alerts[i];
                index++;
            }
        }
        
        return matchingAlerts;
    }
    
    function getMonitoringStats() external view returns (
        uint256 totalRules,
        uint256 activeRules,
        uint256 totalAlerts,
        uint256 unresolvedAlerts,
        uint256 criticalAlerts
    ) {
        totalRules = ruleCounter;
        totalAlerts = alertCounter;
        
        for (uint256 i = 1; i <= ruleCounter; i++) {
            if (eventRules[i].isActive) {
                activeRules++;
            }
        }
        
        for (uint256 i = 1; i <= alertCounter; i++) {
            if (!alerts[i].isResolved) {
                unresolvedAlerts++;
                if (alerts[i].level == AlertLevel.CRITICAL || alerts[i].level == AlertLevel.EMERGENCY) {
                    criticalAlerts++;
                }
            }
        }
    }
    
    // Utility function to convert uint to string
    function _uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
    
    // Emergency functions
    function emergencyPauseAllRules() external onlyOwner {
        for (uint256 i = 1; i <= ruleCounter; i++) {
            eventRules[i].isActive = false;
        }
    }
    
    function emergencyResumeAllRules() external onlyOwner {
        for (uint256 i = 1; i <= ruleCounter; i++) {
            eventRules[i].isActive = true;
        }
    }
}
