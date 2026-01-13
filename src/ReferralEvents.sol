// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ReferralTypes.sol";

/**
 * @title ReferralEvents
 * @notice Events for referral system
 */
abstract contract ReferralEvents is ReferralTypes {
    /// @notice Emitted when referrer registers
    event ReferrerRegistered(address indexed referrer, bytes32 referralCode);

    /// @notice Emitted when referral is recorded
    event ReferralRecorded(
        address indexed referrer,
        address indexed referee,
        uint256 rewardAmount
    );

    /// @notice Emitted when rewards are claimed
    event RewardsClaimed(address indexed referrer, uint256 amount);

    /// @notice Emitted when tier is upgraded
    event TierUpgraded(address indexed referrer, ReferralTier oldTier, ReferralTier newTier);

    /// @notice Emitted when rewards pool is funded
    event RewardsPoolFunded(address indexed funder, uint256 amount);

    /// @notice Emitted when referrer is deactivated
    event ReferrerDeactivated(address indexed referrer);

    /// @notice Emitted when referral code is updated
    event ReferralCodeUpdated(address indexed referrer, bytes32 oldCode, bytes32 newCode);
}
