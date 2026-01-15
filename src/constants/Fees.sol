// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Fees
 * @notice Fee constants for protocol
 */
library Fees {
    uint256 public constant DEFAULT_DEPOSIT_FEE_BPS = 50;   // 0.5%
    uint256 public constant MAX_DEPOSIT_FEE_BPS = 200;      // 2%
    uint256 public constant REFERRAL_FEE_BPS = 100;         // 1%
    uint256 public constant EMERGENCY_WITHDRAW_FEE_BPS = 0; // No fee
    uint256 public constant BPS_DENOMINATOR = 10000;

    function calculateFee(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return (amount * feeBps) / BPS_DENOMINATOR;
    }

    function amountAfterFee(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return amount - calculateFee(amount, feeBps);
    }

    /// @notice Yield performance fee (taken from yield profits)
    uint256 public constant YIELD_PERFORMANCE_FEE_BPS = 500; // 5%

    /// @notice Early withdrawal penalty
    uint256 public constant EARLY_WITHDRAWAL_PENALTY_BPS = 100; // 1%

    /// @notice Calculate yield performance fee
    function calculateYieldFee(uint256 yieldAmount) internal pure returns (uint256) {
        return (yieldAmount * YIELD_PERFORMANCE_FEE_BPS) / BPS_DENOMINATOR;
    }
}
