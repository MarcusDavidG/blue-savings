// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title CrossChainBridge
 * @notice Simple bridge interface for cross-chain vault deposits
 */
contract CrossChainBridge {
    using SafeERC20 for IERC20;

    struct BridgeRequest {
        address sender;
        address token;
        uint256 amount;
        uint256 destChainId;
        address destAddress;
        uint256 timestamp;
        bool processed;
    }

    uint256 public requestCounter;
    address public owner;
    address public relayer;

    mapping(uint256 => BridgeRequest) public requests;
    mapping(uint256 => bool) public supportedChains;

    event BridgeInitiated(uint256 indexed requestId, address indexed sender, uint256 destChainId, uint256 amount);
    event BridgeCompleted(uint256 indexed requestId, address indexed recipient, uint256 amount);

    error UnsupportedChain();
    error Unauthorized();
    error AlreadyProcessed();

    modifier onlyRelayer() {
        if (msg.sender != relayer) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        relayer = msg.sender;
    }

    function setSupportedChain(uint256 chainId, bool supported) external {
        require(msg.sender == owner, "Not owner");
        supportedChains[chainId] = supported;
    }

    function setRelayer(address _relayer) external {
        require(msg.sender == owner, "Not owner");
        relayer = _relayer;
    }

    function initiateBridge(
        address token,
        uint256 amount,
        uint256 destChainId,
        address destAddress
    ) external returns (uint256 requestId) {
        if (!supportedChains[destChainId]) revert UnsupportedChain();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        requestId = requestCounter++;
        requests[requestId] = BridgeRequest({
            sender: msg.sender,
            token: token,
            amount: amount,
            destChainId: destChainId,
            destAddress: destAddress,
            timestamp: block.timestamp,
            processed: false
        });

        emit BridgeInitiated(requestId, msg.sender, destChainId, amount);
    }

    function completeBridge(uint256 requestId, address recipient, address token, uint256 amount) external onlyRelayer {
        if (requests[requestId].processed) revert AlreadyProcessed();
        requests[requestId].processed = true;

        IERC20(token).safeTransfer(recipient, amount);
        emit BridgeCompleted(requestId, recipient, amount);
    }
}
