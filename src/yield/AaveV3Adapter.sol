// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BaseYieldAdapter.sol";
import "../interfaces/IAaveV3Pool.sol";

/**
 * @title AaveV3Adapter
 * @notice Yield adapter for Aave V3 protocol
 * @dev Deposits tokens into Aave V3 to earn yield
 */
contract AaveV3Adapter is BaseYieldAdapter {
    using SafeERC20 for IERC20;

    /// @notice Aave V3 Pool address
    IAaveV3Pool public immutable aavePool;

    /// @notice Mapping of token to aToken address
    mapping(address => address) public aTokens;

    /// @notice Ray (1e27) for rate calculations
    uint256 constant RAY = 1e27;

    constructor(address _vault, address _aavePool) BaseYieldAdapter(_vault) {
        aavePool = IAaveV3Pool(_aavePool);
    }

    /// @notice Set aToken address for underlying token
    function setAToken(address token, address aToken) external onlyOwner {
        aTokens[token] = aToken;
        supportedTokens[token] = true;
        emit TokenSupported(token, true);
    }

    /// @notice Deposit tokens into Aave
    function deposit(address token, uint256 amount) 
        external 
        override 
        onlyVault 
        supportedToken(token) 
        returns (uint256 shares) 
    {
        if (amount == 0) revert ZeroAmount();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(aavePool), amount);

        uint256 aTokenBefore = IERC20(aTokens[token]).balanceOf(address(this));
        aavePool.supply(token, amount, address(this), 0);
        uint256 aTokenAfter = IERC20(aTokens[token]).balanceOf(address(this));

        shares = aTokenAfter - aTokenBefore;
        emit Deposited(token, amount, shares);
    }

    /// @notice Withdraw tokens from Aave
    function withdraw(address token, uint256 amount) 
        external 
        override 
        onlyVault 
        supportedToken(token) 
        returns (uint256 withdrawn) 
    {
        if (amount == 0) revert ZeroAmount();

        withdrawn = aavePool.withdraw(token, amount, vault);
        emit Withdrawn(token, withdrawn);
    }

    /// @notice Get balance including yield
    function getBalance(address token, address) 
        external 
        view 
        override 
        returns (uint256) 
    {
        return IERC20(aTokens[token]).balanceOf(address(this));
    }

    /// @notice Get current APY from Aave
    function getAPY(address token) external view override returns (uint256) {
        (,, uint128 currentLiquidityRate,,,,,,,,,,,,) = aavePool.getReserveData(token);
        // Convert ray to basis points (1e27 to 1e4)
        return (uint256(currentLiquidityRate) * 10000) / RAY;
    }

    /// @notice Protocol name
    function protocolName() external pure override returns (string memory) {
        return "Aave V3";
    }

    function _deposit(address, uint256) internal pure override returns (uint256) {
        return 0; // Implemented in public deposit
    }

    function _withdraw(address, uint256) internal pure override returns (uint256) {
        return 0; // Implemented in public withdraw
    }

    function _getBalance(address, address) internal pure override returns (uint256) {
        return 0; // Implemented in public getBalance
    }
}
