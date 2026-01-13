// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/ReferralSystem.sol";

contract ReferralSystemTest is Test {
    ReferralSystem public referral;

    address public referrer1;
    address public referee1;
    address public referee2;

    bytes32 constant CODE1 = keccak256("MYCODE123");

    function setUp() public {
        referrer1 = makeAddr("referrer1");
        referee1 = makeAddr("referee1");
        referee2 = makeAddr("referee2");

        referral = new ReferralSystem();

        // Fund rewards pool
        vm.deal(address(this), 100 ether);
        referral.fundRewardsPool{value: 10 ether}();
    }

    function test_RegisterAsReferrer() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        ReferralTypes.Referrer memory ref = referral.getReferrer(referrer1);
        assertEq(ref.referralCode, CODE1);
        assertTrue(ref.isActive);
        assertEq(uint256(ref.tier), uint256(ReferralTypes.ReferralTier.Bronze));
    }

    function test_RecordReferral() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        referral.recordReferral(referee1, CODE1);

        assertTrue(referral.hasReferrer(referee1));
        assertEq(referral.getReferralCount(referrer1), 1);
    }

    function test_CreditReward() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        referral.recordReferral(referee1, CODE1);
        referral.creditReward(referee1, 1 ether);

        ReferralTypes.Referrer memory ref = referral.getReferrer(referrer1);
        assertGt(ref.unclaimedRewards, 0);
    }

    function test_ClaimRewards() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        referral.recordReferral(referee1, CODE1);
        referral.creditReward(referee1, 1 ether);

        uint256 balanceBefore = referrer1.balance;

        vm.prank(referrer1);
        referral.claimRewards();

        uint256 balanceAfter = referrer1.balance;
        assertGt(balanceAfter, balanceBefore);
    }

    function test_TierUpgrade() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        // Create 5 referrals to reach Silver
        for (uint256 i = 0; i < 5; i++) {
            address newReferee = makeAddr(string(abi.encodePacked("referee", i)));
            referral.recordReferral(newReferee, CODE1);
        }

        ReferralTypes.Referrer memory ref = referral.getReferrer(referrer1);
        assertEq(uint256(ref.tier), uint256(ReferralTypes.ReferralTier.Silver));
    }

    function test_RevertOnDuplicateCode() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        address referrer2 = makeAddr("referrer2");
        vm.prank(referrer2);
        vm.expectRevert(abi.encodeWithSelector(
            ReferralErrors.CodeAlreadyTaken.selector,
            CODE1
        ));
        referral.registerAsReferrer(CODE1);
    }

    function test_RevertOnSelfReferral() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(CODE1);

        vm.expectRevert(ReferralErrors.CannotReferSelf.selector);
        referral.recordReferral(referrer1, CODE1);
    }
}
