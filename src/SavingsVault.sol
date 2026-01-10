// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

/// @title BlueSavings Vault Contract
/// @author BlueSavings Team
/// @notice A savings vault protocol for time-locked and goal-based savings on Base
contract SavingsVault {
    /// @notice Represents a savings vault with lock conditions and metadata
    /// @dev Stores all vault state including balance, goals, and ownership
    struct Vault {
        address owner;
        uint256 balance;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        bool isActive;
        uint256 createdAt;
        string metadata;
    }

    // Constants
    /// @notice Maximum protocol fee (2%)
    uint256 public constant MAX_FEE_BPS = 200;
    
        /// @notice Basis points denominator (10000 = 100%)
    
        uint256 public constant BPS_DENOMINATOR = 10000;
    
        
    
        // State variables
    uint256 public vaultCounter;
    
        uint256 public feeBps = 50; // 0.5% default
    
        uint256 public totalFeesCollected;
    
        address public owner;
    
        // Mappings
    mapping(uint256 => Vault) public vaults;
    mapping(address => uint256[]) public userVaults;
    
    // Events
    /// @notice Emitted when a new vault is created
    /// @param vaultId Unique identifier for the vault
    /// @param owner Address of vault owner
    /// @param goalAmount Savings goal amount
    /// @param unlockTimestamp Time when vault unlocks
    /// @param metadata Vault name or description
    event VaultCreated(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string metadata
    );
    
    /// @notice Emitted when vault metadata is updated
    /// @param vaultId Vault whose metadata changed
    /// @param metadata New metadata value
    event VaultMetadataUpdated(
        uint256 indexed vaultId,
        string metadata
    );
    
    /// @notice Emitted when ETH is deposited into a vault
    /// @param vaultId Vault that received the deposit
    /// @param depositor Address that made the deposit
    /// @param amount Net amount credited to vault
    /// @param feeAmount Protocol fee charged
    event Deposited(
        uint256 indexed vaultId,
        address indexed depositor,
        uint256 amount,
        uint256 feeAmount
    );
    
    /// @notice Emitted when funds are withdrawn from a vault
    /// @param vaultId Vault that was withdrawn from
    /// @param owner Vault owner who withdrew
    /// @param amount Amount withdrawn in wei
    event Withdrawn(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 amount
    );
    
    /// @notice Emitted when protocol fees are collected
    /// @param collector Address that collected fees
    /// @param amount Fee amount collected in wei
    event FeeCollected(address indexed collector, uint256 amount);
    /// @notice Emitted when protocol fee is updated
    /// @param oldFee Previous fee in basis points
    /// @param newFee New fee in basis points
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    // Custom errors
    /// @notice Thrown when caller is not authorized for action
    error Unauthorized();
    /// @notice Thrown when vault is not active
    error VaultNotActive();
    /// @notice Thrown when vault is still locked
    error VaultLocked();
    /// @notice Thrown when goal amount not yet reached
    error GoalNotReached();
    /// @notice Thrown when amount is invalid (e.g., zero)
    error InvalidAmount();
    /// @notice Thrown when fee exceeds maximum allowed
    error InvalidFee();
    /// @notice Thrown when parameters are invalid
    error InvalidParameters();
    /// @notice Thrown when ETH transfer fails
    error TransferFailed();
    
        // Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    modifier onlyVaultOwner(uint256 vaultId) {
        if (vaults[vaultId].owner != msg.sender) revert Unauthorized();
        _;
    }
    
        // Constructor
    constructor() {
        owner = msg.sender;
    }
    
    // External functions
    /// @notice Creates a new savings vault with optional time lock and goal
    /// @param goalAmount Target savings amount (0 for no goal requirement)
    /// @param unlockTimestamp Unix timestamp when vault unlocks (0 for immediate access)
    /// @param metadata Vault name or description for identification
    /// @return vaultId The unique identifier for the created vault
    function createVault(
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string calldata metadata
    ) external returns (uint256) {
        if (unlockTimestamp != 0 && unlockTimestamp <= block.timestamp) {
            revert InvalidParameters();
        }
        
        uint256 vaultId = vaultCounter++;
        
        vaults[vaultId] = Vault({
            owner: msg.sender,
            balance: 0,
            goalAmount: goalAmount,
            unlockTimestamp: unlockTimestamp,
            isActive: true,
            createdAt: block.timestamp,
            metadata: metadata
        });
        
        userVaults[msg.sender].push(vaultId);
        
        emit VaultCreated(vaultId, msg.sender, goalAmount, unlockTimestamp, metadata);
        
        return vaultId;
    }
    
    /// @notice Deposit ETH into a vault with protocol fee deduction
    /// @dev Charges feeBps percentage as protocol fee
    /// @param vaultId The ID of the vault to deposit into
    function deposit(uint256 vaultId) external payable {
        if (msg.value == 0) revert InvalidAmount();
        
        Vault storage vault = vaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();
        
        // Calculate protocol fee and net deposit amount
        uint256 feeAmount = (msg.value * feeBps) / BPS_DENOMINATOR;
        uint256 depositAmount = msg.value - feeAmount;
        
        vault.balance += depositAmount;
        totalFeesCollected += feeAmount;
        
        emit Deposited(vaultId, msg.sender, depositAmount, feeAmount);
    }
    
    /// @notice Withdraw funds from vault when unlock conditions are met
    /// @dev Requires unlock time passed and goal amount reached
    /// @param vaultId The ID of the vault to withdraw from
    function withdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        Vault storage vault = vaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();
        
        // Verify unlock time has passed if set
        if (vault.unlockTimestamp != 0 && block.timestamp < vault.unlockTimestamp) {
            revert VaultLocked();
        }
        
        // Verify goal amount reached if set
        if (vault.goalAmount != 0 && vault.balance < vault.goalAmount) {
            revert GoalNotReached();
        }
        
        uint256 amount = vault.balance;
        vault.balance = 0;
        vault.isActive = false;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();
        
        emit Withdrawn(vaultId, msg.sender, amount);
    }
    
    /// @notice Emergency withdrawal bypassing lock conditions
    /// @dev Allows vault owner to withdraw anytime, use with caution
    /// @param vaultId The ID of the vault to emergency withdraw from
    function emergencyWithdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        Vault storage vault = vaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();
        
        uint256 amount = vault.balance;
        vault.balance = 0;
        vault.isActive = false;
        
        (bool success, ) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();
        
        emit Withdrawn(vaultId, msg.sender, amount);
    }
    
    /// @notice Update vault metadata (name/description)
    /// @dev Only vault owner can update metadata
    /// @param vaultId The ID of the vault to update
    /// @param metadata New vault name or description
    function setVaultMetadata(uint256 vaultId, string calldata metadata) external onlyVaultOwner(vaultId) {
        vaults[vaultId].metadata = metadata;
        
        emit VaultMetadataUpdated(vaultId, metadata);
    }
    
    /// @notice Collect accumulated protocol fees
    /// @dev Only contract owner can collect fees
    function collectFees() external onlyOwner {
        uint256 amount = totalFeesCollected;
        totalFeesCollected = 0;
        
        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();
        
        emit FeeCollected(owner, amount);
    }
    
    /// @notice Update protocol fee percentage
    /// @dev Fee is capped at MAX_FEE_BPS (2%)
    /// @param newFeeBps New fee in basis points (100 = 1%)
    function setFeeBps(uint256 newFeeBps) external onlyOwner {
        if (newFeeBps > MAX_FEE_BPS) revert InvalidFee();
        
        uint256 oldFee = feeBps;
        feeBps = newFeeBps;
        
        emit FeeUpdated(oldFee, newFeeBps);
    }
    
    /// @notice Transfer contract ownership to new address
    /// @dev New owner cannot be zero address
    /// @param newOwner Address of the new contract owner
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidParameters();
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    // View functions
    /// @notice Get all vault IDs owned by a user
    /// @param user Address to query vaults for
    /// @return Array of vault IDs owned by the user
    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }
    
    /// @notice Get comprehensive vault information
    /// @param vaultId The ID of the vault to query
    /// @return vaultOwner Owner address of the vault
    /// @return balance Current ETH balance in the vault
    /// @return goalAmount Target savings goal (0 if none)
    /// @return unlockTimestamp Time when vault unlocks (0 if no lock)
    /// @return isActive Whether vault is still active
    /// @return createdAt Timestamp when vault was created
    /// @return metadata Vault name or description
    /// @return canWithdraw Whether vault can be withdrawn now
    function getVaultDetails(uint256 vaultId) external view returns (
        address vaultOwner,
        uint256 balance,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        bool isActive,
        uint256 createdAt,
        string memory metadata,
        bool canWithdraw
    ) {
        Vault memory vault = vaults[vaultId];
        
        bool canWithdrawNow = vault.isActive &&
            (vault.unlockTimestamp == 0 || block.timestamp >= vault.unlockTimestamp) &&
            (vault.goalAmount == 0 || vault.balance >= vault.goalAmount);
        
        return (
            vault.owner,
            vault.balance,
            vault.goalAmount,
            vault.unlockTimestamp,
            vault.isActive,
            vault.createdAt,
            vault.metadata,
            canWithdrawNow
        );
    }
    
    /// @notice Calculate protocol fee for a deposit amount
    /// @param amount The deposit amount in wei
    /// @return fee The protocol fee amount
    /// @return netDeposit Amount credited to vault after fee
    function calculateDepositFee(uint256 amount) external view returns (uint256 fee, uint256 netDeposit) {
        fee = (amount * feeBps) / BPS_DENOMINATOR;
        netDeposit = amount - fee;
    }
}
