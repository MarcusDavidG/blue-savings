// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./libraries/SafeERC20.sol";
import "./TokenWhitelist.sol";
import "./TokenVaultStorage.sol";
import "./TokenFeeManager.sol";

/**
 * @title TokenSavingsVault
 * @notice ERC-20 token savings vault with time-lock and goal-based savings
 * @dev Extends the base savings vault concept to support multiple tokens
 */
contract TokenSavingsVault is TokenWhitelist, TokenVaultStorage, TokenFeeManager {
    using SafeERC20 for IERC20;

    /// @notice Vault structure for token-based savings
    struct TokenVault {
        address owner;
        address goalToken;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        bool isActive;
        uint256 createdAt;
        string metadata;
    }

    // Constants
    uint256 public constant MAX_FEE_BPS = 200;
    uint256 public constant BPS_DENOMINATOR = 10000;

    // State
    uint256 public tokenVaultCounter;
    uint256 public tokenFeeBps = 50; // 0.5% default
    address public owner;

    // Mappings
    mapping(uint256 => TokenVault) public tokenVaults;
    mapping(address => uint256[]) public userTokenVaults;

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

    event TokenFeeBpsUpdated(uint256 oldFee, uint256 newFee);

    // Errors
    error Unauthorized();
    error VaultNotActive();
    error VaultLocked();
    error GoalNotReached();
    error InvalidAmount();
    error InvalidFee();
    error InvalidParameters();
    error NonexistentVault();
    error NoTokenBalance();

    // Modifiers
    modifier onlyContractOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyTokenVaultOwner(uint256 vaultId) {
        if (tokenVaults[vaultId].owner != msg.sender) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Whitelist a token for deposits (owner only)
    function whitelistToken(address token) external onlyContractOwner {
        _whitelistToken(token);
    }

    /// @notice Remove a token from whitelist (owner only)
    function delistToken(address token) external onlyContractOwner {
        _delistToken(token);
    }

    /// @notice Create a new token savings vault
    function createTokenVault(
        address goalToken,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string calldata metadata
    ) external returns (uint256) {
        if (unlockTimestamp != 0 && unlockTimestamp <= block.timestamp) {
            revert InvalidParameters();
        }

        uint256 vaultId;
        unchecked {
            vaultId = tokenVaultCounter++;
        }

        tokenVaults[vaultId] = TokenVault({
            owner: msg.sender,
            goalToken: goalToken,
            goalAmount: goalAmount,
            unlockTimestamp: unlockTimestamp,
            isActive: true,
            createdAt: block.timestamp,
            metadata: metadata
        });

        userTokenVaults[msg.sender].push(vaultId);

        emit TokenVaultCreated(vaultId, msg.sender, goalToken, goalAmount, unlockTimestamp, metadata);

        return vaultId;
    }

    /// @notice Deposit tokens into a vault
    function depositToken(
        uint256 vaultId,
        address token,
        uint256 amount
    ) external onlyWhitelistedToken(token) {
        if (amount == 0) revert InvalidAmount();

        TokenVault storage vault = tokenVaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();

        uint256 feeAmount = (amount * tokenFeeBps) / BPS_DENOMINATOR;
        uint256 depositAmount;
        unchecked {
            depositAmount = amount - feeAmount;
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        _addTokenToVault(vaultId, token);
        unchecked {
            vaultTokenBalances[vaultId][token] += depositAmount;
        }
        _addTokenFee(token, feeAmount);

        emit TokenDeposited(vaultId, msg.sender, token, depositAmount, feeAmount);
    }

    /// @notice Withdraw tokens from a vault
    function withdrawToken(
        uint256 vaultId,
        address token
    ) external onlyTokenVaultOwner(vaultId) {
        TokenVault storage vault = tokenVaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();

        if (vault.unlockTimestamp != 0 && block.timestamp < vault.unlockTimestamp) {
            revert VaultLocked();
        }

        if (vault.goalToken != address(0) && vault.goalAmount != 0) {
            if (vaultTokenBalances[vaultId][vault.goalToken] < vault.goalAmount) {
                revert GoalNotReached();
            }
        }

        uint256 amount = vaultTokenBalances[vaultId][token];
        if (amount == 0) revert NoTokenBalance();

        vaultTokenBalances[vaultId][token] = 0;
        _removeTokenFromVault(vaultId, token);

        IERC20(token).safeTransfer(msg.sender, amount);

        emit TokenWithdrawn(vaultId, msg.sender, token, amount);
    }

    /// @notice Emergency withdraw tokens (bypasses locks)
    function emergencyWithdrawToken(
        uint256 vaultId,
        address token
    ) external onlyTokenVaultOwner(vaultId) {
        TokenVault storage vault = tokenVaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();

        uint256 amount = vaultTokenBalances[vaultId][token];
        if (amount == 0) revert NoTokenBalance();

        vaultTokenBalances[vaultId][token] = 0;
        _removeTokenFromVault(vaultId, token);

        IERC20(token).safeTransfer(msg.sender, amount);

        emit TokenWithdrawn(vaultId, msg.sender, token, amount);
    }

    /// @notice Collect accumulated token fees (owner only)
    function collectTokenFees(address token) external onlyContractOwner {
        uint256 amount = _resetTokenFees(token);
        if (amount == 0) revert InvalidAmount();

        IERC20(token).safeTransfer(owner, amount);

        emit TokenFeeCollected(token, owner, amount);
    }

    /// @notice Update token fee percentage
    function setTokenFeeBps(uint256 newFeeBps) external onlyContractOwner {
        if (newFeeBps > MAX_FEE_BPS) revert InvalidFee();

        uint256 oldFee = tokenFeeBps;
        tokenFeeBps = newFeeBps;

        emit TokenFeeBpsUpdated(oldFee, newFeeBps);
    }

    /// @notice Transfer contract ownership
    function transferOwnership(address newOwner) external onlyContractOwner {
        if (newOwner == address(0)) revert InvalidParameters();
        owner = newOwner;
    }

    /// @notice Get user's token vault IDs
    function getUserTokenVaults(address user) external view returns (uint256[] memory) {
        return userTokenVaults[user];
    }

    /// @notice Get token vault details
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
        )
    {
        TokenVault memory vault = tokenVaults[vaultId];
        return (
            vault.owner,
            vault.goalToken,
            vault.goalAmount,
            vault.unlockTimestamp,
            vault.isActive,
            vault.createdAt,
            vault.metadata
        );
    }
}
