// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title RewardDistributor
 * @notice Distribute rewards to vault depositors
 */
contract RewardDistributor {
    using SafeERC20 for IERC20;

    struct Epoch {
        uint256 totalRewards;
        uint256 totalShares;
        uint256 startTime;
        uint256 endTime;
    }

    IERC20 public rewardToken;
    address public owner;
    uint256 public currentEpoch;
    uint256 public epochDuration = 7 days;

    mapping(uint256 => Epoch) public epochs;
    mapping(uint256 => mapping(address => uint256)) public userShares;
    mapping(uint256 => mapping(address => bool)) public hasClaimed;

    event EpochStarted(uint256 indexed epoch, uint256 totalRewards);
    event SharesRecorded(uint256 indexed epoch, address indexed user, uint256 shares);
    event RewardClaimed(uint256 indexed epoch, address indexed user, uint256 amount);

    error EpochNotEnded();
    error AlreadyClaimed();
    error NoShares();

    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
        owner = msg.sender;
    }

    function startEpoch(uint256 totalRewards) external {
        require(msg.sender == owner, "Not owner");

        rewardToken.safeTransferFrom(msg.sender, address(this), totalRewards);

        currentEpoch++;
        epochs[currentEpoch] = Epoch({
            totalRewards: totalRewards,
            totalShares: 0,
            startTime: block.timestamp,
            endTime: block.timestamp + epochDuration
        });

        emit EpochStarted(currentEpoch, totalRewards);
    }

    function recordShares(address user, uint256 shares) external {
        require(msg.sender == owner, "Not owner");

        userShares[currentEpoch][user] += shares;
        epochs[currentEpoch].totalShares += shares;

        emit SharesRecorded(currentEpoch, user, shares);
    }

    function claimReward(uint256 epoch) external {
        if (block.timestamp < epochs[epoch].endTime) revert EpochNotEnded();
        if (hasClaimed[epoch][msg.sender]) revert AlreadyClaimed();
        if (userShares[epoch][msg.sender] == 0) revert NoShares();

        hasClaimed[epoch][msg.sender] = true;

        uint256 reward = (epochs[epoch].totalRewards * userShares[epoch][msg.sender]) / epochs[epoch].totalShares;
        rewardToken.safeTransfer(msg.sender, reward);

        emit RewardClaimed(epoch, msg.sender, reward);
    }

    function pendingReward(uint256 epoch, address user) external view returns (uint256) {
        if (epochs[epoch].totalShares == 0) return 0;
        return (epochs[epoch].totalRewards * userShares[epoch][user]) / epochs[epoch].totalShares;
    }
}
