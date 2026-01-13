// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/oracle/ChainlinkPriceFeed.sol";
import "../../src/mocks/MockChainlinkAggregator.sol";

contract ChainlinkPriceFeedTest is Test {
    ChainlinkPriceFeed public priceFeed;
    MockChainlinkAggregator public ethFeed;
    address public weth;

    function setUp() public {
        weth = makeAddr("weth");
        
        priceFeed = new ChainlinkPriceFeed();
        ethFeed = new MockChainlinkAggregator(2000e8, 8); // $2000
        
        priceFeed.setFeed(weth, address(ethFeed));
    }

    function test_GetPrice() public view {
        (uint256 price, uint8 decimals) = priceFeed.getPrice(weth);
        assertEq(price, 2000e8);
        assertEq(decimals, 8);
    }

    function test_GetLatestPrice() public view {
        uint256 price = priceFeed.getLatestPrice(weth);
        assertEq(price, 2000e8);
    }

    function test_RevertStalePrice() public {
        ethFeed.setUpdatedAt(block.timestamp - 2 hours);
        
        vm.expectRevert(ChainlinkPriceFeed.StalePrice.selector);
        priceFeed.getPrice(weth);
    }

    function test_RevertFeedNotSet() public {
        address unknown = makeAddr("unknown");
        
        vm.expectRevert(ChainlinkPriceFeed.FeedNotSet.selector);
        priceFeed.getPrice(unknown);
    }
}
