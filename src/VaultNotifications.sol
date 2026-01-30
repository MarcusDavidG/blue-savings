// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultNotifications
 * @dev On-chain notification system for vault events and milestones
 */
contract VaultNotifications {
    struct Notification {
        uint256 id;
        address recipient;
        uint256 vaultId;
        NotificationType notificationType;
        string message;
        uint256 timestamp;
        bool isRead;
        bytes data;
    }
    
    enum NotificationType {
        DEPOSIT_RECEIVED,
        GOAL_REACHED,
        UNLOCK_TIME_REACHED,
        WITHDRAWAL_COMPLETED,
        MILESTONE_ACHIEVED,
        REMINDER,
        EMERGENCY_ALERT,
        YIELD_EARNED,
        INSURANCE_CLAIM,
        GOVERNANCE_PROPOSAL
    }
    
    struct NotificationPreferences {
        bool depositNotifications;
        bool goalNotifications;
        bool unlockNotifications;
        bool withdrawalNotifications;
        bool milestoneNotifications;
        bool reminderNotifications;
        bool emergencyNotifications;
        bool yieldNotifications;
        bool insuranceNotifications;
        bool governanceNotifications;
    }
    
    mapping(address => Notification[]) private userNotifications;
    mapping(address => NotificationPreferences) public preferences;
    mapping(uint256 => address[]) private vaultSubscribers;
    
    uint256 private notificationCounter;
    address public owner;
    address public savingsVault;
    
    event NotificationSent(
        uint256 indexed notificationId,
        address indexed recipient,
        uint256 indexed vaultId,
        NotificationType notificationType
    );
    
    event NotificationRead(uint256 indexed notificationId, address indexed user);
    event PreferencesUpdated(address indexed user);
    event SubscriptionAdded(address indexed user, uint256 indexed vaultId);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }
    
    modifier onlyVault() {
        require(msg.sender == savingsVault, "Only vault can call");
        _;
    }
    
    constructor(address _savingsVault) {
        owner = msg.sender;
        savingsVault = _savingsVault;
    }
    
    /**
     * @dev Send notification to user
     */
    function sendNotification(
        address recipient,
        uint256 vaultId,
        NotificationType notificationType,
        string memory message,
        bytes memory data
    ) external onlyVault {
        if (!shouldSendNotification(recipient, notificationType)) {
            return;
        }
        
        uint256 notificationId = ++notificationCounter;
        
        Notification memory notification = Notification({
            id: notificationId,
            recipient: recipient,
            vaultId: vaultId,
            notificationType: notificationType,
            message: message,
            timestamp: block.timestamp,
            isRead: false,
            data: data
        });
        
        userNotifications[recipient].push(notification);
        
        emit NotificationSent(notificationId, recipient, vaultId, notificationType);
    }
    
    /**
     * @dev Batch send notifications to multiple users
     */
    function batchSendNotification(
        address[] memory recipients,
        uint256 vaultId,
        NotificationType notificationType,
        string memory message,
        bytes memory data
    ) external onlyVault {
        for (uint256 i = 0; i < recipients.length; i++) {
            if (shouldSendNotification(recipients[i], notificationType)) {
                uint256 notificationId = ++notificationCounter;
                
                Notification memory notification = Notification({
                    id: notificationId,
                    recipient: recipients[i],
                    vaultId: vaultId,
                    notificationType: notificationType,
                    message: message,
                    timestamp: block.timestamp,
                    isRead: false,
                    data: data
                });
                
                userNotifications[recipients[i]].push(notification);
                
                emit NotificationSent(notificationId, recipients[i], vaultId, notificationType);
            }
        }
    }
    
    /**
     * @dev Get user notifications
     */
    function getUserNotifications(address user) external view returns (Notification[] memory) {
        return userNotifications[user];
    }
    
    /**
     * @dev Get unread notifications count
     */
    function getUnreadCount(address user) external view returns (uint256) {
        Notification[] memory notifications = userNotifications[user];
        uint256 unreadCount = 0;
        
        for (uint256 i = 0; i < notifications.length; i++) {
            if (!notifications[i].isRead) {
                unreadCount++;
            }
        }
        
        return unreadCount;
    }
    
    /**
     * @dev Mark notification as read
     */
    function markAsRead(uint256 notificationIndex) external {
        require(notificationIndex < userNotifications[msg.sender].length, "Invalid index");
        
        userNotifications[msg.sender][notificationIndex].isRead = true;
        
        emit NotificationRead(
            userNotifications[msg.sender][notificationIndex].id,
            msg.sender
        );
    }
    
    /**
     * @dev Mark all notifications as read
     */
    function markAllAsRead() external {
        Notification[] storage notifications = userNotifications[msg.sender];
        
        for (uint256 i = 0; i < notifications.length; i++) {
            if (!notifications[i].isRead) {
                notifications[i].isRead = true;
                emit NotificationRead(notifications[i].id, msg.sender);
            }
        }
    }
    
    /**
     * @dev Update notification preferences
     */
    function updatePreferences(NotificationPreferences memory newPreferences) external {
        preferences[msg.sender] = newPreferences;
        emit PreferencesUpdated(msg.sender);
    }
    
    /**
     * @dev Subscribe to vault notifications
     */
    function subscribeToVault(uint256 vaultId) external {
        address[] storage subscribers = vaultSubscribers[vaultId];
        
        // Check if already subscribed
        for (uint256 i = 0; i < subscribers.length; i++) {
            if (subscribers[i] == msg.sender) {
                return; // Already subscribed
            }
        }
        
        subscribers.push(msg.sender);
        emit SubscriptionAdded(msg.sender, vaultId);
    }
    
    /**
     * @dev Unsubscribe from vault notifications
     */
    function unsubscribeFromVault(uint256 vaultId) external {
        address[] storage subscribers = vaultSubscribers[vaultId];
        
        for (uint256 i = 0; i < subscribers.length; i++) {
            if (subscribers[i] == msg.sender) {
                // Move last element to current position and pop
                subscribers[i] = subscribers[subscribers.length - 1];
                subscribers.pop();
                break;
            }
        }
    }
    
    /**
     * @dev Get vault subscribers
     */
    function getVaultSubscribers(uint256 vaultId) external view returns (address[] memory) {
        return vaultSubscribers[vaultId];
    }
    
    /**
     * @dev Send reminder notifications for upcoming unlock times
     */
    function sendUnlockReminders(uint256[] memory vaultIds, uint256[] memory unlockTimes) external onlyOwner {
        require(vaultIds.length == unlockTimes.length, "Array length mismatch");
        
        for (uint256 i = 0; i < vaultIds.length; i++) {
            if (unlockTimes[i] <= block.timestamp + 24 hours && unlockTimes[i] > block.timestamp) {
                address[] memory subscribers = vaultSubscribers[vaultIds[i]];
                
                for (uint256 j = 0; j < subscribers.length; j++) {
                    if (shouldSendNotification(subscribers[j], NotificationType.REMINDER)) {
                        uint256 notificationId = ++notificationCounter;
                        
                        Notification memory notification = Notification({
                            id: notificationId,
                            recipient: subscribers[j],
                            vaultId: vaultIds[i],
                            notificationType: NotificationType.REMINDER,
                            message: "Your vault will unlock in less than 24 hours!",
                            timestamp: block.timestamp,
                            isRead: false,
                            data: abi.encode(unlockTimes[i])
                        });
                        
                        userNotifications[subscribers[j]].push(notification);
                        
                        emit NotificationSent(notificationId, subscribers[j], vaultIds[i], NotificationType.REMINDER);
                    }
                }
            }
        }
    }
    
    /**
     * @dev Clear old notifications (older than 30 days)
     */
    function clearOldNotifications(address user) external {
        require(msg.sender == user || msg.sender == owner, "Not authorized");
        
        Notification[] storage notifications = userNotifications[user];
        uint256 cutoffTime = block.timestamp - 30 days;
        
        // Remove old notifications by shifting array
        uint256 writeIndex = 0;
        for (uint256 readIndex = 0; readIndex < notifications.length; readIndex++) {
            if (notifications[readIndex].timestamp >= cutoffTime) {
                if (writeIndex != readIndex) {
                    notifications[writeIndex] = notifications[readIndex];
                }
                writeIndex++;
            }
        }
        
        // Resize array
        while (notifications.length > writeIndex) {
            notifications.pop();
        }
    }
    
    /**
     * @dev Check if notification should be sent based on preferences
     */
    function shouldSendNotification(address user, NotificationType notificationType) 
        internal 
        view 
        returns (bool) 
    {
        NotificationPreferences memory prefs = preferences[user];
        
        if (notificationType == NotificationType.DEPOSIT_RECEIVED) return prefs.depositNotifications;
        if (notificationType == NotificationType.GOAL_REACHED) return prefs.goalNotifications;
        if (notificationType == NotificationType.UNLOCK_TIME_REACHED) return prefs.unlockNotifications;
        if (notificationType == NotificationType.WITHDRAWAL_COMPLETED) return prefs.withdrawalNotifications;
        if (notificationType == NotificationType.MILESTONE_ACHIEVED) return prefs.milestoneNotifications;
        if (notificationType == NotificationType.REMINDER) return prefs.reminderNotifications;
        if (notificationType == NotificationType.EMERGENCY_ALERT) return prefs.emergencyNotifications;
        if (notificationType == NotificationType.YIELD_EARNED) return prefs.yieldNotifications;
        if (notificationType == NotificationType.INSURANCE_CLAIM) return prefs.insuranceNotifications;
        if (notificationType == NotificationType.GOVERNANCE_PROPOSAL) return prefs.governanceNotifications;
        
        return true; // Default to sending if type not recognized
    }
}
