// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title IAerodromeRouter
 * @notice Interface for Aerodrome Router on Base
 */
interface IAerodromeRouter {
    struct Route {
        address from;
        address to;
        bool stable;
        address factory;
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        Route[] calldata routes,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function getAmountsOut(
        uint256 amountIn,
        Route[] calldata routes
    ) external view returns (uint256[] memory amounts);

    function defaultFactory() external view returns (address);
}

/**
 * @title AerodromeAdapter
 * @notice Integrates with Aerodrome DEX for token swaps on Base
 * @dev Allows swapping tokens before vault deposits using Base's native DEX
 * @author BlueSavings Team
 */
contract AerodromeAdapter {
    using SafeERC20 for IERC20;

    /// @notice Aerodrome Router on Base mainnet
    IAerodromeRouter public immutable router;

    /// @notice Contract owner
    address public owner;

    /// @notice Default slippage tolerance (0.5%)
    uint256 public slippageBps = 50;

    /// @notice Basis points denominator
    uint256 public constant BPS_DENOMINATOR = 10000;

    /// @notice Approved vault contracts that can use this adapter
    mapping(address => bool) public approvedVaults;

    event SwapExecuted(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );
    event VaultApproved(address indexed vault, bool approved);
    event SlippageUpdated(uint256 oldSlippage, uint256 newSlippage);

    error Unauthorized();
    error InvalidRoute();
    error SlippageExceeded();
    error ZeroAmount();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyApprovedVault() {
        if (!approvedVaults[msg.sender] && msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor(address _router) {
        router = IAerodromeRouter(_router);
        owner = msg.sender;
    }

    /// @notice Approve a vault to use this adapter
    function setVaultApproval(address vault, bool approved) external onlyOwner {
        approvedVaults[vault] = approved;
        emit VaultApproved(vault, approved);
    }

    /// @notice Update slippage tolerance
    function setSlippage(uint256 newSlippageBps) external onlyOwner {
        require(newSlippageBps <= 500, "Slippage too high"); // Max 5%
        emit SlippageUpdated(slippageBps, newSlippageBps);
        slippageBps = newSlippageBps;
    }

    /// @notice Swap tokens using Aerodrome
    /// @param tokenIn Input token address
    /// @param tokenOut Output token address
    /// @param amountIn Amount of input tokens
    /// @param stable Whether to use stable or volatile pool
    /// @return amountOut Amount of output tokens received
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        bool stable
    ) external returns (uint256 amountOut) {
        if (amountIn == 0) revert ZeroAmount();

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        IAerodromeRouter.Route[] memory routes = new IAerodromeRouter.Route[](1);
        routes[0] = IAerodromeRouter.Route({
            from: tokenIn,
            to: tokenOut,
            stable: stable,
            factory: router.defaultFactory()
        });

        uint256[] memory expectedAmounts = router.getAmountsOut(amountIn, routes);
        uint256 minOut = (expectedAmounts[1] * (BPS_DENOMINATOR - slippageBps)) / BPS_DENOMINATOR;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            minOut,
            routes,
            msg.sender,
            block.timestamp + 300
        );

        amountOut = amounts[amounts.length - 1];
        emit SwapExecuted(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    /// @notice Get expected output amount for a swap
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        bool stable
    ) external view returns (uint256) {
        IAerodromeRouter.Route[] memory routes = new IAerodromeRouter.Route[](1);
        routes[0] = IAerodromeRouter.Route({
            from: tokenIn,
            to: tokenOut,
            stable: stable,
            factory: router.defaultFactory()
        });

        uint256[] memory amounts = router.getAmountsOut(amountIn, routes);
        return amounts[1];
    }

    /// @notice Swap and deposit to vault in one transaction
    function swapAndDeposit(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        bool stable,
        address vault,
        uint256 vaultId
    ) external returns (uint256 deposited) {
        if (!approvedVaults[vault]) revert Unauthorized();

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(address(router), amountIn);

        IAerodromeRouter.Route[] memory routes = new IAerodromeRouter.Route[](1);
        routes[0] = IAerodromeRouter.Route({
            from: tokenIn,
            to: tokenOut,
            stable: stable,
            factory: router.defaultFactory()
        });

        uint256[] memory expectedAmounts = router.getAmountsOut(amountIn, routes);
        uint256 minOut = (expectedAmounts[1] * (BPS_DENOMINATOR - slippageBps)) / BPS_DENOMINATOR;

        uint256[] memory amounts = router.swapExactTokensForTokens(
            amountIn,
            minOut,
            routes,
            address(this),
            block.timestamp + 300
        );

        deposited = amounts[amounts.length - 1];

        IERC20(tokenOut).approve(vault, deposited);
        (bool success,) = vault.call(
            abi.encodeWithSignature(
                "depositToken(uint256,address,uint256)",
                vaultId,
                tokenOut,
                deposited
            )
        );
        require(success, "Deposit failed");

        emit SwapExecuted(msg.sender, tokenIn, tokenOut, amountIn, deposited);
    }

    /// @notice Rescue stuck tokens (emergency)
    function rescueTokens(address token, uint256 amount) external onlyOwner {
        IERC20(token).safeTransfer(owner, amount);
    }
}
