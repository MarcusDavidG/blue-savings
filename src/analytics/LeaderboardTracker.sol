// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title LeaderboardTracker
 * @notice Track top depositors and savers
 */
contract LeaderboardTracker {
    struct Entry {
        address user;
        uint256 totalSaved;
        uint256 vaultCount;
        uint256 longestLock;
    }

    Entry[] public leaderboard;
    mapping(address => uint256) public userIndex;
    mapping(address => bool) public isOnLeaderboard;

    uint256 public constant MAX_ENTRIES = 100;

    event LeaderboardUpdated(address indexed user, uint256 totalSaved, uint256 rank);

    function updateUser(address user, uint256 totalSaved, uint256 vaultCount, uint256 longestLock) external {
        if (isOnLeaderboard[user]) {
            uint256 index = userIndex[user];
            leaderboard[index].totalSaved = totalSaved;
            leaderboard[index].vaultCount = vaultCount;
            leaderboard[index].longestLock = longestLock;
        } else if (leaderboard.length < MAX_ENTRIES) {
            userIndex[user] = leaderboard.length;
            isOnLeaderboard[user] = true;
            leaderboard.push(Entry(user, totalSaved, vaultCount, longestLock));
        } else {
            uint256 minIndex = _findMinEntry();
            if (totalSaved > leaderboard[minIndex].totalSaved) {
                isOnLeaderboard[leaderboard[minIndex].user] = false;
                leaderboard[minIndex] = Entry(user, totalSaved, vaultCount, longestLock);
                userIndex[user] = minIndex;
                isOnLeaderboard[user] = true;
            }
        }

        _sortLeaderboard();
        emit LeaderboardUpdated(user, totalSaved, _getRank(user));
    }

    function _findMinEntry() internal view returns (uint256 minIndex) {
        uint256 minValue = type(uint256).max;
        for (uint256 i = 0; i < leaderboard.length; i++) {
            if (leaderboard[i].totalSaved < minValue) {
                minValue = leaderboard[i].totalSaved;
                minIndex = i;
            }
        }
    }

    function _sortLeaderboard() internal {
        for (uint256 i = 0; i < leaderboard.length; i++) {
            for (uint256 j = i + 1; j < leaderboard.length; j++) {
                if (leaderboard[j].totalSaved > leaderboard[i].totalSaved) {
                    Entry memory temp = leaderboard[i];
                    leaderboard[i] = leaderboard[j];
                    leaderboard[j] = temp;
                    userIndex[leaderboard[i].user] = i;
                    userIndex[leaderboard[j].user] = j;
                }
            }
        }
    }

    function _getRank(address user) internal view returns (uint256) {
        if (!isOnLeaderboard[user]) return 0;
        return userIndex[user] + 1;
    }

    function getTopN(uint256 n) external view returns (Entry[] memory) {
        uint256 count = n < leaderboard.length ? n : leaderboard.length;
        Entry[] memory top = new Entry[](count);
        for (uint256 i = 0; i < count; i++) {
            top[i] = leaderboard[i];
        }
        return top;
    }

    function getRank(address user) external view returns (uint256) {
        return _getRank(user);
    }
}
