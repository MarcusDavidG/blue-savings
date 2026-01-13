// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultTemplateTypes
 * @notice Type definitions for vault templates
 * @dev Structs and enums for preset vault configurations
 */
abstract contract VaultTemplateTypes {
    /// @notice Template category for organization
    enum TemplateCategory {
        Emergency,      // Emergency fund templates
        Retirement,     // Long-term retirement savings
        Vacation,       // Vacation/travel savings
        Education,      // Education fund
        Purchase,       // Large purchase savings
        Custom          // User-defined templates
    }

    /// @notice Vault template configuration
    struct VaultTemplate {
        string name;
        string description;
        TemplateCategory category;
        uint256 suggestedGoal;          // Suggested goal amount (0 for flexible)
        uint256 suggestedLockDays;      // Suggested lock duration in days
        address suggestedToken;          // Suggested token (address(0) for ETH)
        bool isActive;
        address creator;
        uint256 usageCount;
        uint256 createdAt;
    }

    /// @notice Parameters for creating vault from template
    struct TemplateParams {
        uint256 templateId;
        uint256 goalAmount;             // Override suggested goal
        uint256 unlockTimestamp;        // Override suggested lock
        address goalToken;              // Override suggested token
        string metadata;
    }
}
