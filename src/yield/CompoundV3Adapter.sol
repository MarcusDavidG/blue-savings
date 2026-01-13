// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BaseYieldAdapter.sol";
import "../interfaces/ICompoundV3.sol";

/**
 * @title CompoundV3Adapter
 * @notice Yield adapter for Compound V3 (Comet)
 * @dev Deposits tokens into Compound V3 to earn yield
 */
contract CompoundV3Adapter is BaseYieldAdapter {
    using SafeERC20 for IERC20;

    /// @notice Compound V3 Comet contract
    ICompoundV3 public immutable comet;

    /// @notice Seconds per year for APY calculation
    uint256 constant SECONDS_PER_YEAR = 365 days;

    constructor(address _vault, address _comet) BaseYieldAdapter(_vault) {
        comet = ICompoundV3(_comet);
        // Base token is automatically supported
        supportedTokens[comet.baseToken()] = true;
    }

    /// @notice Deposit tokens into Compound
    function deposit(address token, uint256 amount) 
        external 
        override 
        onlyVault 
        supportedToken(token) 
        returns (uint256 shares) 
    {
        if (amount == 0) revert ZeroAmount();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(token).approve(address(comet), amount);

        uint256 balanceBefore = comet.balanceOf(address(this));
        comet.supply(token, amount);
        uint256 balanceAfter = comet.balanceOf(address(this));

        shares = balanceAfter - balanceBefore;
        emit Deposited(token, amount, shares);
    }

    /// @notice Withdraw tokens from Compound
    function withdraw(address token, uint256 amount) 
        external 
        override 
        onlyVault 
        supportedToken(token) 
        returns (uint256 withdrawn) 
    {
        if (amount == 0) revert ZeroAmount();

        comet.withdrawTo(vault, token, amount);
        withdrawn = amount;
        emit Withdrawn(token, withdrawn);
    }

    /// @notice Get balance including yield
    function getBalance(address, address) 
        external 
        view 
        override 
        returns (uint256) 
    {
        return comet.balanceOf(address(this));
    }

    /// @notice Get current APY from Compound
    function getAPY(address) external view override returns (uint256) {
        uint256 utilization = comet.getUtilization();
        uint64 supplyRate = comet.getSupplyRate(utilization);
        // Convert per-second rate to APY in basis points
        // supplyRate is scaled by 1e18
        return (uint256(supplyRate) * SECONDS_PER_YEAR * 10000) / 1e18;
    }

    /// @notice Protocol name
    function protocolName() external pure override returns (string memory) {
        return "Compound V3";
    }

    function _deposit(address, uint256) internal pure override returns (uint256) {
        return 0;
    }

    function _withdraw(address, uint256) internal pure override returns (uint256) {
        return 0;
    }

    function _getBalance(address, address) internal pure override returns (uint256) {
        return 0;
    }
}
