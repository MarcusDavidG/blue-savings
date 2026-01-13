// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title VestedStaking
 * @notice Staking with vesting schedules
 */
contract VestedStaking {
    using SafeERC20 for IERC20;

    struct Stake {
        uint256 amount;
        uint256 startTime;
        uint256 vestingDuration;
        uint256 claimed;
    }

    IERC20 public immutable token;
    mapping(address => Stake[]) public stakes;

    event Staked(address indexed user, uint256 amount, uint256 vestingDuration);
    event Claimed(address indexed user, uint256 amount);

    error NothingToClaim();
    error InvalidDuration();

    constructor(address _token) {
        token = IERC20(_token);
    }

    function stake(uint256 amount, uint256 vestingDuration) external {
        if (vestingDuration < 30 days) revert InvalidDuration();

        token.safeTransferFrom(msg.sender, address(this), amount);

        stakes[msg.sender].push(Stake({
            amount: amount,
            startTime: block.timestamp,
            vestingDuration: vestingDuration,
            claimed: 0
        }));

        emit Staked(msg.sender, amount, vestingDuration);
    }

    function claimable(address user, uint256 stakeIndex) public view returns (uint256) {
        Stake memory s = stakes[user][stakeIndex];
        if (block.timestamp < s.startTime) return 0;

        uint256 elapsed = block.timestamp - s.startTime;
        uint256 vested;

        if (elapsed >= s.vestingDuration) {
            vested = s.amount;
        } else {
            vested = (s.amount * elapsed) / s.vestingDuration;
        }

        return vested - s.claimed;
    }

    function claim(uint256 stakeIndex) external {
        uint256 amount = claimable(msg.sender, stakeIndex);
        if (amount == 0) revert NothingToClaim();

        stakes[msg.sender][stakeIndex].claimed += amount;
        token.safeTransfer(msg.sender, amount);

        emit Claimed(msg.sender, amount);
    }

    function getStakeCount(address user) external view returns (uint256) {
        return stakes[user].length;
    }

    function getStake(address user, uint256 index) external view returns (Stake memory) {
        return stakes[user][index];
    }
}
