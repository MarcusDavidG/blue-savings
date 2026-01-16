// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultMath
 * @notice Vault-specific calculations
 */
library VaultMath {
    uint256 constant BPS = 10000;

    function calculateFee(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return (amount * feeBps) / BPS;
    }

    function amountAfterFee(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return amount - calculateFee(amount, feeBps);
    }

    function calculateProgress(uint256 current, uint256 goal) internal pure returns (uint256) {
        if (goal == 0) return BPS;
        if (current >= goal) return BPS;
        return (current * BPS) / goal;
    }

    function calculateRemaining(uint256 current, uint256 goal) internal pure returns (uint256) {
        if (current >= goal) return 0;
        return goal - current;
    }

    function interpolateAPY(uint256 baseAPY, uint256 bonusAPY, uint256 lockDays, uint256 maxLockDays) 
        internal pure returns (uint256) 
    {
        if (lockDays >= maxLockDays) return baseAPY + bonusAPY;
        return baseAPY + (bonusAPY * lockDays) / maxLockDays;
    }

    /// @notice Calculate compound interest
    function calculateCompoundInterest(
        uint256 principal,
        uint256 rate,
        uint256 periods
    ) internal pure returns (uint256) {
        uint256 amount = principal;
        for (uint256 i = 0; i < periods; i++) {
            amount = amount + (amount * rate) / BPS;
        }
        return amount;
    }

    /// @notice Calculate simple interest
    function calculateSimpleInterest(
        uint256 principal,
        uint256 rate,
        uint256 periods
    ) internal pure returns (uint256) {
        return principal + (principal * rate * periods) / BPS;
    }
}
