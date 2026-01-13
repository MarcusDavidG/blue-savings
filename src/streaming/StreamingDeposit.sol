// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title StreamingDeposit
 * @notice Stream tokens into vault over time
 */
contract StreamingDeposit {
    using SafeERC20 for IERC20;

    struct Stream {
        address sender;
        address token;
        uint256 vaultId;
        uint256 totalAmount;
        uint256 startTime;
        uint256 endTime;
        uint256 withdrawn;
    }

    Stream[] public streams;
    mapping(address => uint256[]) public userStreams;

    event StreamCreated(uint256 indexed streamId, address indexed sender, uint256 amount, uint256 duration);
    event StreamWithdrawn(uint256 indexed streamId, uint256 amount);

    function createStream(
        address token,
        uint256 vaultId,
        uint256 totalAmount,
        uint256 duration
    ) external returns (uint256 streamId) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), totalAmount);

        streamId = streams.length;
        streams.push(Stream({
            sender: msg.sender,
            token: token,
            vaultId: vaultId,
            totalAmount: totalAmount,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            withdrawn: 0
        }));

        userStreams[msg.sender].push(streamId);
        emit StreamCreated(streamId, msg.sender, totalAmount, duration);
    }

    function withdrawable(uint256 streamId) public view returns (uint256) {
        Stream memory stream = streams[streamId];
        if (block.timestamp <= stream.startTime) return 0;

        uint256 elapsed = block.timestamp >= stream.endTime 
            ? stream.endTime - stream.startTime 
            : block.timestamp - stream.startTime;
        uint256 duration = stream.endTime - stream.startTime;
        uint256 vested = (stream.totalAmount * elapsed) / duration;

        return vested - stream.withdrawn;
    }

    function withdraw(uint256 streamId) external {
        uint256 amount = withdrawable(streamId);
        require(amount > 0, "Nothing to withdraw");

        streams[streamId].withdrawn += amount;
        IERC20(streams[streamId].token).safeTransfer(msg.sender, amount);

        emit StreamWithdrawn(streamId, amount);
    }
}
