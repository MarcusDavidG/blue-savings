// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";
import "./YieldManager.sol";

/**
 * @title YieldVault
 * @notice Savings vault with automatic yield generation
 * @dev Integrates with YieldManager for yield strategies
 */
contract YieldVault {
    using SafeERC20 for IERC20;

    struct YieldVaultData {
        address owner;
        uint256 principalDeposited;
        uint256 yieldEarned;
        address token;
        bool autoCompound;
        uint256 createdAt;
    }

    /// @notice Yield manager contract
    YieldManager public yieldManager;

    /// @notice Vault counter
    uint256 public vaultCounter;

    /// @notice Contract owner
    address public owner;

    /// @notice Mapping of vault ID to data
    mapping(uint256 => YieldVaultData) public vaults;

    /// @notice User's vault IDs
    mapping(address => uint256[]) public userVaults;

    // Events
    event YieldVaultCreated(uint256 indexed vaultId, address indexed owner, address token);
    event YieldDeposited(uint256 indexed vaultId, uint256 amount);
    event YieldWithdrawn(uint256 indexed vaultId, uint256 principal, uint256 yield);
    event YieldHarvested(uint256 indexed vaultId, uint256 amount);

    // Errors
    error Unauthorized();
    error InvalidAmount();
    error VaultNotFound();

    modifier onlyVaultOwner(uint256 vaultId) {
        if (vaults[vaultId].owner != msg.sender) revert Unauthorized();
        _;
    }

    constructor(address _yieldManager) {
        owner = msg.sender;
        yieldManager = YieldManager(_yieldManager);
    }

    /// @notice Create a yield-generating vault
    function createYieldVault(address token, bool autoCompound) external returns (uint256 vaultId) {
        vaultId = vaultCounter++;

        vaults[vaultId] = YieldVaultData({
            owner: msg.sender,
            principalDeposited: 0,
            yieldEarned: 0,
            token: token,
            autoCompound: autoCompound,
            createdAt: block.timestamp
        });

        userVaults[msg.sender].push(vaultId);
        emit YieldVaultCreated(vaultId, msg.sender, token);
    }

    /// @notice Deposit and start earning yield
    function deposit(uint256 vaultId, uint256 amount) external onlyVaultOwner(vaultId) {
        if (amount == 0) revert InvalidAmount();

        YieldVaultData storage vault = vaults[vaultId];

        IERC20(vault.token).safeTransferFrom(msg.sender, address(this), amount);
        IERC20(vault.token).approve(address(yieldManager), amount);

        yieldManager.depositToYield(vault.token, amount);
        vault.principalDeposited += amount;

        emit YieldDeposited(vaultId, amount);
    }

    /// @notice Withdraw principal and yield
    function withdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        YieldVaultData storage vault = vaults[vaultId];

        uint256 totalBalance = yieldManager.getTotalBalance(vault.token);
        uint256 yieldAmount = totalBalance > vault.principalDeposited 
            ? totalBalance - vault.principalDeposited 
            : 0;

        yieldManager.withdrawFromYield(vault.token, totalBalance);

        vault.yieldEarned += yieldAmount;
        uint256 principal = vault.principalDeposited;
        vault.principalDeposited = 0;

        emit YieldWithdrawn(vaultId, principal, yieldAmount);
    }

    /// @notice Get vault details
    function getVaultDetails(uint256 vaultId) external view returns (YieldVaultData memory) {
        return vaults[vaultId];
    }

    /// @notice Get user's vaults
    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }

    /// @notice Get current yield for vault
    function getCurrentYield(uint256 vaultId) external view returns (uint256) {
        YieldVaultData memory vault = vaults[vaultId];
        uint256 totalBalance = yieldManager.getTotalBalance(vault.token);
        return totalBalance > vault.principalDeposited 
            ? totalBalance - vault.principalDeposited 
            : 0;
    }
}
