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
        uint256 indexed vaultId, address indexed owner, uint256 goalAmount, uint256 unlockTimestamp, string metadata
    );

    /// @notice Emitted when vault metadata is updated
    /// @param vaultId Vault whose metadata changed
    /// @param metadata New metadata value
    event VaultMetadataUpdated(uint256 indexed vaultId, string metadata);

    /// @notice Emitted when ETH is deposited into a vault
    /// @param vaultId Vault that received the deposit
    /// @param depositor Address that made the deposit
    /// @param amount Net amount credited to vault
    /// @param feeAmount Protocol fee charged
    event Deposited(uint256 indexed vaultId, address indexed depositor, uint256 amount, uint256 feeAmount);

    /// @notice Emitted when funds are withdrawn from a vault
    /// @param vaultId Vault that was withdrawn from
    /// @param owner Vault owner who withdrew
    /// @param amount Amount withdrawn in wei
    event Withdrawn(uint256 indexed vaultId, address indexed owner, uint256 amount);

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
    /// @notice Thrown when vault does not exist
    error NonexistentVault();

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

        uint256 vaultId;
        unchecked {
            vaultId = vaultCounter++;
        }

        address _sender = msg.sender; // Cache msg.sender

        vaults[vaultId] = Vault({
            owner: _sender,
            balance: 0,
            goalAmount: goalAmount,
            unlockTimestamp: unlockTimestamp,
            isActive: true,
            createdAt: block.timestamp,
            metadata: metadata
        });

        userVaults[_sender].push(vaultId);

        emit VaultCreated(vaultId, _sender, goalAmount, unlockTimestamp, metadata);

        return vaultId;
    }

    /// @notice Deposit ETH into a vault with protocol fee deduction

    /// @dev Charges feeBps percentage as protocol fee

    /// @param vaultId The ID of the vault to deposit into

    function deposit(uint256 vaultId) external payable {
        uint256 _msgValue = msg.value; // Cache msg.value
        if (_msgValue == 0) revert InvalidAmount();

        Vault storage vault = vaults[vaultId];
        bool _isActive = vault.isActive; // Cache
        if (!_isActive) revert VaultNotActive();

        // Calculate protocol fee and net deposit amount
        uint256 _feeBps = feeBps; // Cache storage read
        uint256 feeAmount = (_msgValue * _feeBps) / BPS_DENOMINATOR;
        uint256 depositAmount;
        unchecked {
            depositAmount = _msgValue - feeAmount; // Safe: feeAmount < _msgValue
        }

        unchecked {
            vault.balance += depositAmount;
            totalFeesCollected += feeAmount;
        }

        address _depositor = msg.sender; // Cache msg.sender
        emit Deposited(vaultId, _depositor, depositAmount, feeAmount);
    }

    /// @notice Withdraw funds from vault when unlock conditions are met

    /// @dev Requires unlock time passed and goal amount reached

    /// @param vaultId The ID of the vault to withdraw from

    function withdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        Vault storage vault = vaults[vaultId];
        bool _isActive = vault.isActive; // Cache
        if (!_isActive) revert VaultNotActive();

        // Verify unlock time has passed if set
        uint256 _unlockTime = vault.unlockTimestamp; // Cache
        if (_unlockTime != 0 && block.timestamp < _unlockTime) {
            revert VaultLocked();
        }

        // Verify goal amount reached if set
        uint256 _balance = vault.balance; // Cache balance

        // Verify goal amount reached if set
        uint256 _goalAmount = vault.goalAmount; // Cache
        if (_goalAmount != 0 && _balance < _goalAmount) {
            revert GoalNotReached();
        }

        uint256 amount = _balance;
        vault.balance = 0;
        vault.isActive = false;

        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) revert TransferFailed();

        emit Withdrawn(vaultId, msg.sender, amount);
    }

    /// @notice Emergency withdrawal bypassing lock conditions

    /// @dev Allows vault owner to withdraw anytime, use with caution

    /// @param vaultId The ID of the vault to emergency withdraw from

    function emergencyWithdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        Vault storage vault = vaults[vaultId];
        bool _isActive = vault.isActive; // Cache
        if (!_isActive) revert VaultNotActive();

        uint256 amount = vault.balance;
        vault.balance = 0;
        vault.isActive = false;

        (bool success,) = payable(msg.sender).call{value: amount}("");
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

        address _owner = owner; // Cache owner
        (bool success,) = payable(_owner).call{value: amount}("");
        if (!success) revert TransferFailed();

        emit FeeCollected(_owner, amount);
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
    /// @notice Get the total number of vaults created
    /// @return Total vault count
    function getTotalVaults() external view returns (uint256) {
        return vaultCounter;
    }

    /// @notice Get count of active vaults for a user
    /// @param user Address to query
    /// @return count Number of active vaults
    function getActiveVaultCount(address user) external view returns (uint256 count) {
        uint256[] memory userVaultIds = userVaults[user];
        uint256 length = userVaultIds.length;

        for (uint256 i = 0; i < length;) {
            if (vaults[userVaultIds[i]].isActive) {
                unchecked {
                    ++count;
                }
            }
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Get total deposited amount across all user vaults
    /// @param user Address to query
    /// @return total Total deposited amount in wei
    function getTotalDepositsForUser(address user) external view returns (uint256 total) {
        uint256[] memory userVaultIds = userVaults[user];
        uint256 length = userVaultIds.length;

        for (uint256 i = 0; i < length;) {
            total += vaults[userVaultIds[i]].balance;
            unchecked {
                ++i;
            }
        }
    }

    /// @notice Check if vault is unlocked (time-wise)
    /// @param vaultId Vault to check
    /// @return True if vault has no time lock or time has passed
    function isVaultUnlocked(uint256 vaultId) external view returns (bool) {
        uint256 unlockTime = vaults[vaultId].unlockTimestamp;
        return unlockTime == 0 || block.timestamp >= unlockTime;
    }

    /// @notice Check if vault goal is reached
    /// @param vaultId Vault to check
    /// @return True if no goal set or goal is reached
    function isGoalReached(uint256 vaultId) external view returns (bool) {
        Vault memory vault = vaults[vaultId];
        return vault.goalAmount == 0 || vault.balance >= vault.goalAmount;
    }

    /// @notice Get vault goal progress percentage (in basis points)
    /// @param vaultId Vault to check
    /// @return progress Progress in bps (10000 = 100%)
    function getVaultProgress(uint256 vaultId) external view returns (uint256 progress) {
        Vault memory vault = vaults[vaultId];

        if (vault.goalAmount == 0) {
            return 10000; // No goal = 100% complete
        }

        if (vault.balance >= vault.goalAmount) {
            return 10000; // Goal reached = 100%
        }

        // Calculate percentage in basis points
        progress = (vault.balance * 10000) / vault.goalAmount;
    }

    /// @notice Get seconds remaining until vault unlocks
    /// @param vaultId Vault to check
    /// @return seconds Seconds until unlock (0 if already unlocked)
    function getTimeUntilUnlock(uint256 vaultId) external view returns (uint256) {
        uint256 unlockTime = vaults[vaultId].unlockTimestamp;

        if (unlockTime == 0 || block.timestamp >= unlockTime) {
            return 0;
        }

        unchecked {
            return unlockTime - block.timestamp;
        }
    }

    /// @notice Get amount remaining to reach goal
    /// @param vaultId Vault to check
    /// @return remaining Amount in wei (0 if goal reached or no goal)
    function getRemainingToGoal(uint256 vaultId) external view returns (uint256 remaining) {
        Vault memory vault = vaults[vaultId];

        if (vault.goalAmount == 0 || vault.balance >= vault.goalAmount) {
            return 0;
        }

        unchecked {
            remaining = vault.goalAmount - vault.balance;
        }
    }

    /// @notice Check if a vault exists
    /// @param vaultId Vault to check
    /// @return exists True if vault was created
    function vaultExists(uint256 vaultId) external view returns (bool exists) {
        // Vault exists if it has an owner (owner is never zero for created vaults)
        return vaults[vaultId].owner != address(0);
    }

    /// @notice Get total value locked in all vaults
    /// @return total Total ETH locked in protocol
    function getTotalProtocolValue() external view returns (uint256 total) {
        // Total = contract balance - uncollected fees
        total = address(this).balance - totalFeesCollected;
    }

    /// @notice Get total contract balance including fees
    /// @return balance Total ETH held by contract
    function getContractBalance() external view returns (uint256 balance) {
        return address(this).balance;
    }

    /// @notice Get vault owner address
    /// @param vaultId Vault to query
    /// @return owner Vault owner address
    function getVaultOwner(uint256 vaultId) external view returns (address owner) {
        return vaults[vaultId].owner;
    }
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
    function getVaultDetails(uint256 vaultId)
        external
        view
        returns (
            address vaultOwner,
            uint256 balance,
            uint256 goalAmount,
            uint256 unlockTimestamp,
            bool isActive,
            uint256 createdAt,
            string memory metadata,
            bool canWithdraw
        )
    {
        Vault memory vault = vaults[vaultId];

        bool canWithdrawNow = vault.isActive && (vault.unlockTimestamp == 0 || block.timestamp >= vault.unlockTimestamp)
            && (vault.goalAmount == 0 || vault.balance >= vault.goalAmount);

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
        uint256 _feeBps = feeBps; // Cache for consistency
        fee = (amount * _feeBps) / BPS_DENOMINATOR;
        unchecked {
            netDeposit = amount - fee; // Safe subtraction
        }
    }
}