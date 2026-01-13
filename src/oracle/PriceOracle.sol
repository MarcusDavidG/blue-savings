// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PriceOracle
 * @notice Simple price oracle for token valuations
 */
contract PriceOracle {
    struct PriceData {
        uint256 price;
        uint256 timestamp;
        uint8 decimals;
    }

    address public owner;
    mapping(address => PriceData) public prices;
    mapping(address => bool) public authorizedUpdaters;

    event PriceUpdated(address indexed token, uint256 price, uint256 timestamp);
    event UpdaterAuthorized(address indexed updater, bool authorized);

    error Unauthorized();
    error StalePrice();

    modifier onlyAuthorized() {
        if (!authorizedUpdaters[msg.sender] && msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        authorizedUpdaters[msg.sender] = true;
    }

    function setPrice(address token, uint256 price, uint8 decimals) external onlyAuthorized {
        prices[token] = PriceData({
            price: price,
            timestamp: block.timestamp,
            decimals: decimals
        });
        emit PriceUpdated(token, price, block.timestamp);
    }

    function getPrice(address token) external view returns (uint256 price, uint256 timestamp) {
        PriceData memory data = prices[token];
        return (data.price, data.timestamp);
    }

    function getLatestPrice(address token, uint256 maxAge) external view returns (uint256) {
        PriceData memory data = prices[token];
        if (block.timestamp - data.timestamp > maxAge) revert StalePrice();
        return data.price;
    }

    function setAuthorizedUpdater(address updater, bool authorized) external {
        require(msg.sender == owner, "Not owner");
        authorizedUpdaters[updater] = authorized;
        emit UpdaterAuthorized(updater, authorized);
    }
}
