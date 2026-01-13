// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BonusCalculator
 * @notice Calculate bonus multipliers for vault deposits
 */
library BonusCalculator {
    uint256 constant BPS = 10000;

    /// @notice Calculate lock duration bonus
    function lockBonus(uint256 lockDays) internal pure returns (uint256) {
        if (lockDays >= 365) return 2500; // 25% bonus
        if (lockDays >= 180) return 1500; // 15% bonus
        if (lockDays >= 90) return 750;   // 7.5% bonus
        if (lockDays >= 30) return 250;   // 2.5% bonus
        return 0;
    }

    /// @notice Calculate deposit amount bonus
    function amountBonus(uint256 amount) internal pure returns (uint256) {
        if (amount >= 100000e18) return 1000; // 10% bonus for whale
        if (amount >= 10000e18) return 500;   // 5% bonus
        if (amount >= 1000e18) return 250;    // 2.5% bonus
        return 0;
    }

    /// @notice Calculate early adopter bonus
    function earlyAdopterBonus(uint256 vaultId) internal pure returns (uint256) {
        if (vaultId < 100) return 2000;   // 20% for first 100
        if (vaultId < 1000) return 1000;  // 10% for first 1000
        if (vaultId < 10000) return 500;  // 5% for first 10000
        return 0;
    }

    /// @notice Calculate total bonus multiplier
    function totalBonus(
        uint256 lockDays,
        uint256 amount,
        uint256 vaultId
    ) internal pure returns (uint256) {
        return BPS + lockBonus(lockDays) + amountBonus(amount) + earlyAdopterBonus(vaultId);
    }

    /// @notice Apply bonus to base amount
    function applyBonus(uint256 baseAmount, uint256 bonusMultiplier) internal pure returns (uint256) {
        return (baseAmount * bonusMultiplier) / BPS;
    }
}
