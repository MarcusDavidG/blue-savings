// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/ReferralSystem.sol";

contract ReferralSystemTest is Test {
    ReferralSystem public referral;
    address public referrer1;
    address public referee1;

    function setUp() public {
        referral = new ReferralSystem();
        referrer1 = makeAddr("referrer1");
        referee1 = makeAddr("referee1");
    }

    function test_RegisterReferrer() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(bytes32("CODE1"));

        (bytes32 code,,,,,,,) = referral.referrers(referrer1);
        assertEq(code, bytes32("CODE1"));
    }

    function test_RecordReferral() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(bytes32("CODE1"));

        referral.recordReferral(referee1, bytes32("CODE1"));

        assertEq(referral.refereeToReferrer(referee1), referrer1);
    }

    function test_RevertSelfReferral() public {
        vm.prank(referrer1);
        referral.registerAsReferrer(bytes32("CODE1"));

        vm.expectRevert();
        referral.recordReferral(referrer1, bytes32("CODE1"));
    }
}
