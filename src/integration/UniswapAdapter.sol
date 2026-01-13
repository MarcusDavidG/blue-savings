// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IUniswapRouter
 * @notice Minimal Uniswap V2 Router interface
 */
interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external view returns (uint256[] memory amounts);
}

/**
 * @title UniswapAdapter
 * @notice Adapter for Uniswap swaps
 */
contract UniswapAdapter {
    IUniswapRouter public immutable router;
    address public owner;

    event Swapped(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    error SlippageExceeded();
    error Unauthorized();

    constructor(address _router) {
        router = IUniswapRouter(_router);
        owner = msg.sender;
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut
    ) external returns (uint256 amountOut) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            minAmountOut,
            path,
            msg.sender,
            block.timestamp
        );

        amountOut = amounts[1];
        if (amountOut < minAmountOut) revert SlippageExceeded();

        emit Swapped(tokenIn, tokenOut, amountIn, amountOut);
    }

    function getQuote(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = router.getAmountsOut(amountIn, path);
        return amounts[1];
    }
}
