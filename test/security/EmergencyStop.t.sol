// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/security/EmergencyStop.sol";

contract EmergencyStopTest is Test {
    EmergencyStop public emergencyStop;
    address public guardian;
    address public randomUser;

    function setUp() public {
        emergencyStop = new EmergencyStop();
        guardian = address(this);
        randomUser = makeAddr("random");
    }

    function test_EmergencyStop() public {
        emergencyStop.emergencyStop("Security issue");
        assertTrue(emergencyStop.isStopped());
    }

    function test_Resume() public {
        emergencyStop.emergencyStop("Test");
        emergencyStop.resume();
        assertFalse(emergencyStop.isStopped());
    }

    function test_AutoExpiry() public {
        emergencyStop.emergencyStop("Test");
        assertTrue(emergencyStop.isStopped());

        vm.warp(block.timestamp + 8 days);
        assertFalse(emergencyStop.isStopped());
    }

    function test_RevertUnauthorizedStop() public {
        vm.prank(randomUser);
        vm.expectRevert(EmergencyStop.NotGuardianOrOwner.selector);
        emergencyStop.emergencyStop("Attack");
    }

    function test_SetGuardian() public {
        address newGuardian = makeAddr("newGuardian");
        emergencyStop.setGuardian(newGuardian);
        assertEq(emergencyStop.guardian(), newGuardian);
    }
}
