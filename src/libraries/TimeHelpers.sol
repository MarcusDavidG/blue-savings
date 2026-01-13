// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TimeHelpers
 * @notice Time calculation utilities
 */
library TimeHelpers {
    uint256 constant SECONDS_PER_MINUTE = 60;
    uint256 constant SECONDS_PER_HOUR = 3600;
    uint256 constant SECONDS_PER_DAY = 86400;
    uint256 constant SECONDS_PER_WEEK = 604800;
    uint256 constant SECONDS_PER_YEAR = 31536000;

    function daysToSeconds(uint256 days_) internal pure returns (uint256) {
        return days_ * SECONDS_PER_DAY;
    }

    function secondsToDays(uint256 seconds_) internal pure returns (uint256) {
        return seconds_ / SECONDS_PER_DAY;
    }

    function weeksToSeconds(uint256 weeks_) internal pure returns (uint256) {
        return weeks_ * SECONDS_PER_WEEK;
    }

    function yearsToSeconds(uint256 years_) internal pure returns (uint256) {
        return years_ * SECONDS_PER_YEAR;
    }

    function hasElapsed(uint256 startTime, uint256 duration) internal view returns (bool) {
        return block.timestamp >= startTime + duration;
    }

    function timeRemaining(uint256 endTime) internal view returns (uint256) {
        if (block.timestamp >= endTime) return 0;
        return endTime - block.timestamp;
    }
}
