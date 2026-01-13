// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ReferralErrors
 * @notice Custom errors for referral system
 */
abstract contract ReferralErrors {
    /// @notice Referral code already taken
    error CodeAlreadyTaken(bytes32 code);

    /// @notice Invalid referral code format
    error InvalidReferralCode();

    /// @notice Referrer not found
    error ReferrerNotFound(address referrer);

    /// @notice Referrer not active
    error ReferrerNotActive(address referrer);

    /// @notice Already has a referrer
    error AlreadyHasReferrer(address referee);

    /// @notice Cannot refer yourself
    error CannotReferSelf();

    /// @notice No rewards to claim
    error NoRewardsToClaim();

    /// @notice Insufficient rewards pool
    error InsufficientRewardsPool(uint256 requested, uint256 available);

    /// @notice Already registered as referrer
    error AlreadyRegistered(address referrer);

    /// @notice Referral code not found
    error CodeNotFound(bytes32 code);
}
