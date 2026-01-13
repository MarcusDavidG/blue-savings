// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ICompoundV3
 * @notice Simplified Compound V3 (Comet) interface
 * @dev Core functions for supply and withdraw
 */
interface ICompoundV3 {
    /// @notice Supply an amount of asset to the protocol
    /// @param asset The asset to supply
    /// @param amount The amount to supply
    function supply(address asset, uint256 amount) external;

    /// @notice Supply an amount of asset on behalf of another address
    /// @param dst The address that will receive the supply
    /// @param asset The asset to supply
    /// @param amount The amount to supply
    function supplyTo(address dst, address asset, uint256 amount) external;

    /// @notice Withdraw an amount of asset from the protocol
    /// @param asset The asset to withdraw
    /// @param amount The amount to withdraw
    function withdraw(address asset, uint256 amount) external;

    /// @notice Withdraw an amount of asset to another address
    /// @param to The address that will receive the withdrawal
    /// @param asset The asset to withdraw
    /// @param amount The amount to withdraw
    function withdrawTo(address to, address asset, uint256 amount) external;

    /// @notice Get the balance of an account
    /// @param account The account to check
    /// @return The balance with accrued interest
    function balanceOf(address account) external view returns (uint256);

    /// @notice Get the current supply rate
    /// @return The supply rate per second (scaled by 1e18)
    function getSupplyRate(uint256 utilization) external view returns (uint64);

    /// @notice Get current utilization
    /// @return The utilization rate (scaled by 1e18)
    function getUtilization() external view returns (uint256);

    /// @notice Get the base token
    /// @return The address of the base asset
    function baseToken() external view returns (address);

    /// @notice Check if asset is in the collateral asset list
    /// @param asset The asset to check
    /// @return True if asset is listed as collateral
    function isAllowed(address, address asset) external view returns (bool);
}
