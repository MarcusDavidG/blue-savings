// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ReferralTypes
 * @notice Type definitions for referral system
 */
abstract contract ReferralTypes {
    /// @notice Referral tier levels
    enum ReferralTier {
        Bronze,     // 0-4 referrals
        Silver,     // 5-14 referrals
        Gold,       // 15-29 referrals
        Platinum,   // 30+ referrals
        Diamond     // 50+ referrals
    }

    /// @notice Referrer information
    struct Referrer {
        bytes32 referralCode;
        uint256 totalReferrals;
        uint256 totalRewardsEarned;
        uint256 unclaimedRewards;
        ReferralTier tier;
        uint256 joinedAt;
        bool isActive;
    }

    /// @notice Referral record
    struct Referral {
        address referrer;
        address referee;
        uint256 timestamp;
        uint256 rewardAmount;
        bool rewardClaimed;
    }

    /// @notice Tier thresholds
    uint256 public constant SILVER_THRESHOLD = 5;
    uint256 public constant GOLD_THRESHOLD = 15;
    uint256 public constant PLATINUM_THRESHOLD = 30;
    uint256 public constant DIAMOND_THRESHOLD = 50;

    /// @notice Reward percentages in basis points
    uint256 public constant BRONZE_REWARD_BPS = 50;    // 0.5%
    uint256 public constant SILVER_REWARD_BPS = 75;    // 0.75%
    uint256 public constant GOLD_REWARD_BPS = 100;     // 1%
    uint256 public constant PLATINUM_REWARD_BPS = 125; // 1.25%
    uint256 public constant DIAMOND_REWARD_BPS = 150;  // 1.5%
}
