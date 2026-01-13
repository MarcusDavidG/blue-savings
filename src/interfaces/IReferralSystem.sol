// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../ReferralTypes.sol";

/**
 * @title IReferralSystem
 * @notice Interface for ReferralSystem
 */
interface IReferralSystem {
    function registerAsReferrer(bytes32 code) external;

    function recordReferral(address referee, bytes32 code) external;

    function creditReward(address referee, uint256 depositAmount) external;

    function claimRewards() external;

    function fundRewardsPool() external payable;

    function getReferrer(address referrer) 
        external 
        view 
        returns (ReferralTypes.Referrer memory);

    function getReferral(uint256 index) 
        external 
        view 
        returns (ReferralTypes.Referral memory);

    function getReferralCount(address referrer) external view returns (uint256);

    function hasReferrer(address referee) external view returns (bool);

    function isCodeTaken(bytes32 code) external view returns (bool);
}
