// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ReferralTypes.sol";

/**
 * @title ReferralStorage
 * @notice Storage layout for referral system
 */
abstract contract ReferralStorage is ReferralTypes {
    /// @notice Mapping of address to referrer info
    mapping(address => Referrer) public referrers;

    /// @notice Mapping of referral code to referrer address
    mapping(bytes32 => address) public codeToReferrer;

    /// @notice Mapping of referee to their referrer
    mapping(address => address) public refereeToReferrer;

    /// @notice Array of all referral records
    Referral[] public referrals;

    /// @notice Mapping of referrer to their referral indices
    mapping(address => uint256[]) public referrerReferrals;

    /// @notice Total rewards pool balance
    uint256 public rewardsPool;

    /// @notice Get referrer info
    function getReferrer(address referrer) external view returns (Referrer memory) {
        return referrers[referrer];
    }

    /// @notice Get referral by index
    function getReferral(uint256 index) external view returns (Referral memory) {
        return referrals[index];
    }

    /// @notice Get referrer's referral count
    function getReferralCount(address referrer) external view returns (uint256) {
        return referrerReferrals[referrer].length;
    }

    /// @notice Check if address has referrer
    function hasReferrer(address referee) external view returns (bool) {
        return refereeToReferrer[referee] != address(0);
    }

    /// @notice Check if code is taken
    function isCodeTaken(bytes32 code) external view returns (bool) {
        return codeToReferrer[code] != address(0);
    }
}
