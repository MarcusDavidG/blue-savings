// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./VaultTemplateTypes.sol";

/**
 * @title DefaultTemplates
 * @notice Provides a library of pre-configured vault templates for common savings goals.
 * @dev These templates offer users a quick way to create vaults with standard configurations,
 * such as lock-in periods and descriptions, tailored to specific financial objectives.
 */
library DefaultTemplates {
    /**
     * @notice Creates a template for an emergency fund.
     * @dev This template is designed for high liquidity, with no lock-in period, allowing users
     * to access their funds at any time in case of an emergency. The suggested goal is left
     * at 0, encouraging users to set a personal target based on their needs.
     * @return name The name of the vault template, "Emergency Fund".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Emergency`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, which is 0 for this template.
     */
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

    /**
     * @notice Creates a template for a vacation fund.
     * @dev This template includes a 6-month lock-in period to help users commit to their
     * savings goal for a future trip.
     * @return name The name of the vault template, "Dream Vacation".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Vacation`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 180.
     */
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

    /**
     * @notice Creates a template for a wedding fund.
     * @dev With a 1-year lock-in period, this template is designed for couples saving
     * for their wedding expenses.
     * @return name The name of the vault template, "Wedding Fund".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Purchase`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 365.
     */
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

    /**
     * @notice Creates a template for a new car fund.
     * @dev This template comes with a 1-year lock-in period, suitable for saving
     * for a significant purchase like a new vehicle.
     * @return name The name of the vault template, "New Car Fund".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Purchase`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 365.
     */
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

    /**
     * @notice Creates a template for a house down payment.
     * @dev A 2-year lock-in period makes this template ideal for long-term savings
     * towards a home purchase.
     * @return name The name of the vault template, "House Down Payment".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Purchase`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 730.
     */
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

    /**
     * @notice Creates a template for an education fund.
     * @dev With a 4-year lock-in period, this template is designed to help save for
     * educational expenses, such as college tuition.
     * @return name The name of the vault template, "Education Fund".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Education`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 1460.
     */
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

    /**
     * @notice Creates a template for a retirement fund.
     * @dev This template features a long-term, 20-year lock-in period, making it
     * suitable for building a retirement nest egg.
     * @return name The name of the vault template, "Retirement Nest Egg".
     * @return description A brief description of the vault's purpose.
     * @return category The category of the vault, `Retirement`.
     * @return suggestedGoal The suggested savings goal, which is 0.
     * @return suggestedLockDays The lock-in period in days, set to 7300.
     */
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
