// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./VaultTemplateTypes.sol";

/**
 * @title DefaultTemplates
 * @notice Pre-configured vault templates for common use cases
 * @dev Library of template configurations
 */
library DefaultTemplates {
    /// @notice Emergency fund template (no lock)
    function emergencyFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "Emergency Fund",
            "3-6 months of expenses for emergencies",
            VaultTemplateTypes.TemplateCategory.Emergency,
            0,
            0
        );
    }

    /// @notice Vacation savings template (6 month lock)
    function vacationFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "Dream Vacation",
            "Save for your next big adventure",
            VaultTemplateTypes.TemplateCategory.Vacation,
            0,
            180
        );
    }

    /// @notice Wedding savings template (1 year lock)
    function weddingFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "Wedding Fund",
            "Save for your special day",
            VaultTemplateTypes.TemplateCategory.Purchase,
            0,
            365
        );
    }

    /// @notice Car purchase template (1 year lock)
    function carFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "New Car Fund",
            "Save for your next vehicle",
            VaultTemplateTypes.TemplateCategory.Purchase,
            0,
            365
        );
    }

    /// @notice House down payment template (2 year lock)
    function houseDownPayment() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "House Down Payment",
            "Save for your home down payment",
            VaultTemplateTypes.TemplateCategory.Purchase,
            0,
            730
        );
    }

    /// @notice Education fund template (4 year lock)
    function educationFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "Education Fund",
            "Save for tuition and education expenses",
            VaultTemplateTypes.TemplateCategory.Education,
            0,
            1460
        );
    }

    /// @notice Retirement template (20 year lock)
    function retirementFund() internal pure returns (
        string memory name,
        string memory description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays
    ) {
        return (
            "Retirement Nest Egg",
            "Long-term retirement savings",
            VaultTemplateTypes.TemplateCategory.Retirement,
            0,
            7300
        );
    }
}
