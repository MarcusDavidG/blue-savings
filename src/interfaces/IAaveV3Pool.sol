// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IAaveV3Pool
 * @notice Simplified Aave V3 Pool interface
 * @dev Core functions for supply and withdraw
 */
interface IAaveV3Pool {
    /// @notice Supply assets to the pool
    /// @param asset The address of the asset to supply
    /// @param amount The amount to supply
    /// @param onBehalfOf Address to receive aTokens
    /// @param referralCode Referral code (0 if none)
    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external;

    /// @notice Withdraw assets from the pool
    /// @param asset The address of the asset to withdraw
    /// @param amount The amount to withdraw (type(uint256).max for all)
    /// @param to Address to receive the underlying asset
    /// @return The final amount withdrawn
    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256);

    /// @notice Get reserve data for an asset
    /// @param asset The address of the asset
    /// @return configuration The reserve configuration
    /// @return liquidityIndex The liquidity index
    /// @return currentLiquidityRate The current supply rate
    /// @return variableBorrowIndex The variable borrow index
    /// @return currentVariableBorrowRate The current variable borrow rate
    /// @return currentStableBorrowRate The current stable borrow rate
    /// @return lastUpdateTimestamp The last update timestamp
    /// @return id The reserve id
    /// @return aTokenAddress The aToken address
    /// @return stableDebtTokenAddress The stable debt token address
    /// @return variableDebtTokenAddress The variable debt token address
    /// @return interestRateStrategyAddress The interest rate strategy address
    /// @return accruedToTreasury The accrued to treasury
    /// @return unbacked The unbacked amount
    /// @return isolationModeTotalDebt The isolation mode total debt
    function getReserveData(address asset)
        external
        view
        returns (
            uint256 configuration,
            uint128 liquidityIndex,
            uint128 currentLiquidityRate,
            uint128 variableBorrowIndex,
            uint128 currentVariableBorrowRate,
            uint128 currentStableBorrowRate,
            uint40 lastUpdateTimestamp,
            uint16 id,
            address aTokenAddress,
            address stableDebtTokenAddress,
            address variableDebtTokenAddress,
            address interestRateStrategyAddress,
            uint128 accruedToTreasury,
            uint128 unbacked,
            uint128 isolationModeTotalDebt
        );
}
