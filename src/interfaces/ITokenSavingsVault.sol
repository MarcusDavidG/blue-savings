// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ITokenSavingsVault
 * @notice Interface for the TokenSavingsVault contract
 * @dev Defines all external functions for token-based savings vaults
 */
interface ITokenSavingsVault {
    // Events
    event TokenVaultCreated(
        uint256 indexed vaultId,
        address indexed vaultOwner,
        address goalToken,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string metadata
    );

    event TokenDeposited(
        uint256 indexed vaultId,
        address indexed depositor,
        address indexed token,
        uint256 amount,
        uint256 feeAmount
    );

    event TokenWithdrawn(
        uint256 indexed vaultId,
        address indexed vaultOwner,
        address indexed token,
        uint256 amount
    );

    // Core Functions
    function createTokenVault(
        address goalToken,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string calldata metadata
    ) external returns (uint256);

    function depositToken(uint256 vaultId, address token, uint256 amount) external;

    function withdrawToken(uint256 vaultId, address token) external;

    function emergencyWithdrawToken(uint256 vaultId, address token) external;

    // View Functions
    function getVaultTokenBalance(uint256 vaultId, address token) external view returns (uint256);

    function getVaultTokens(uint256 vaultId) external view returns (address[] memory);

    function getUserTokenVaults(address user) external view returns (uint256[] memory);

    function getTokenVaultDetails(uint256 vaultId)
        external
        view
        returns (
            address vaultOwner,
            address goalToken,
            uint256 goalAmount,
            uint256 unlockTimestamp,
            bool isActive,
            uint256 createdAt,
            string memory metadata
        );

    // Admin Functions
    function whitelistToken(address token) external;

    function delistToken(address token) external;

    function collectTokenFees(address token) external;

    function setTokenFeeBps(uint256 newFeeBps) external;
}
