// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IChainlinkAggregator
 * @notice Chainlink price feed interface
 */
interface IChainlinkAggregator {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    function decimals() external view returns (uint8);
}

/**
 * @title ChainlinkPriceFeed
 * @notice Wrapper for Chainlink price feeds
 */
contract ChainlinkPriceFeed {
    mapping(address => address) public tokenToFeed;
    address public owner;

    error FeedNotSet();
    error StalePrice();
    error InvalidPrice();

    constructor() {
        owner = msg.sender;
    }

    function setFeed(address token, address feed) external {
        require(msg.sender == owner, "Not owner");
        tokenToFeed[token] = feed;
    }

    function getPrice(address token) external view returns (uint256 price, uint8 decimals) {
        address feed = tokenToFeed[token];
        if (feed == address(0)) revert FeedNotSet();

        IChainlinkAggregator aggregator = IChainlinkAggregator(feed);
        (
            ,
            int256 answer,
            ,
            uint256 updatedAt,
        ) = aggregator.latestRoundData();

        if (answer <= 0) revert InvalidPrice();
        if (block.timestamp - updatedAt > 1 hours) revert StalePrice();

        return (uint256(answer), aggregator.decimals());
    }

    function getLatestPrice(address token) external view returns (uint256) {
        address feed = tokenToFeed[token];
        if (feed == address(0)) revert FeedNotSet();

        (, int256 answer,,,) = IChainlinkAggregator(feed).latestRoundData();
        if (answer <= 0) revert InvalidPrice();

        return uint256(answer);
    }

    /// @notice Staleness threshold (configurable)
    uint256 public stalenessThreshold = 1 hours;

    /// @notice Set staleness threshold
    function setStalenessThreshold(uint256 threshold) external {
        require(msg.sender == owner, "Not owner");
        stalenessThreshold = threshold;
    }

    /// @notice Get USD value of token amount
    function getUsdValue(address token, uint256 amount) external view returns (uint256) {
        address feed = tokenToFeed[token];
        if (feed == address(0)) revert FeedNotSet();

        IChainlinkAggregator aggregator = IChainlinkAggregator(feed);
        (, int256 answer,,,) = aggregator.latestRoundData();
        if (answer <= 0) revert InvalidPrice();

        uint8 feedDecimals = aggregator.decimals();
        // Assuming token has 18 decimals, convert to USD (8 decimals)
        return (amount * uint256(answer)) / (10 ** (18 + feedDecimals - 8));
    }

    /// @notice Check if price feed is healthy
    function isFeedHealthy(address token) external view returns (bool) {
        address feed = tokenToFeed[token];
        if (feed == address(0)) return false;

        try IChainlinkAggregator(feed).latestRoundData() returns (
            uint80, int256 answer, uint256, uint256 updatedAt, uint80
        ) {
            return answer > 0 && (block.timestamp - updatedAt) <= stalenessThreshold;
        } catch {
            return false;
        }
    }
}
