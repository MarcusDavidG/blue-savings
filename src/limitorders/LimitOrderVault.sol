// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title LimitOrderVault
 * @notice Deposit at specific price levels
 */
contract LimitOrderVault {
    struct LimitOrder {
        address owner;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 targetPrice;
        uint256 vaultId;
        bool executed;
        uint256 createdAt;
    }

    LimitOrder[] public orders;
    mapping(address => uint256[]) public userOrders;

    event OrderCreated(uint256 indexed orderId, address indexed owner, uint256 targetPrice);
    event OrderExecuted(uint256 indexed orderId, uint256 executionPrice);
    event OrderCancelled(uint256 indexed orderId);

    function createOrder(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 targetPrice,
        uint256 vaultId
    ) external returns (uint256 orderId) {
        orderId = orders.length;

        orders.push(LimitOrder({
            owner: msg.sender,
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            amountIn: amountIn,
            targetPrice: targetPrice,
            vaultId: vaultId,
            executed: false,
            createdAt: block.timestamp
        }));

        userOrders[msg.sender].push(orderId);
        emit OrderCreated(orderId, msg.sender, targetPrice);
    }

    function executeOrder(uint256 orderId, uint256 currentPrice) external {
        LimitOrder storage order = orders[orderId];
        require(!order.executed, "Already executed");
        require(currentPrice <= order.targetPrice, "Price not reached");

        order.executed = true;
        emit OrderExecuted(orderId, currentPrice);
    }

    function cancelOrder(uint256 orderId) external {
        require(orders[orderId].owner == msg.sender, "Not owner");
        require(!orders[orderId].executed, "Already executed");

        orders[orderId].executed = true; // Mark as done
        emit OrderCancelled(orderId);
    }

    function getUserOrders(address user) external view returns (uint256[] memory) {
        return userOrders[user];
    }
}
