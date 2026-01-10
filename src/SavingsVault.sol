// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title BlueSavings Vault Contract
contract SavingsVault {
    struct Vault {
        address owner;
        uint256 balance;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        bool isActive;
        uint256 createdAt;
        string metadata;
    }

    uint256 public constant MAX_FEE_BPS = 200; // 2% max
    uint256 public constant BPS_DENOMINATOR = 10000;
    
    uint256 public vaultCounter;
    uint256 public feeBps = 50; // 0.5% default
    uint256 public totalFeesCollected;
    address public owner;
    
    mapping(uint256 => Vault) public vaults;
    mapping(address => uint256[]) public userVaults;
    
    event VaultCreated(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string metadata
    );
    
    event VaultMetadataUpdated(
        uint256 indexed vaultId,
        string metadata
    );
    
    event Deposited(
        uint256 indexed vaultId,
        address indexed depositor,
        uint256 amount,
        uint256 feeAmount
    );
    
    event Withdrawn(
        uint256 indexed vaultId,
        address indexed owner,
        uint256 amount
    );
    
    event FeeCollected(address indexed collector, uint256 amount);
    event FeeUpdated(uint256 oldFee, uint256 newFee);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    error Unauthorized();
    error VaultNotActive();
    error VaultLocked();
    error GoalNotReached();
    error InvalidAmount();
    error InvalidFee();
    error InvalidParameters();
    error TransferFailed();
    
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }
    
    modifier onlyVaultOwner(uint256 vaultId) {
        if (vaults[vaultId].owner != msg.sender) revert Unauthorized();
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
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
    
    function deposit(uint256 vaultId) external payable {
        if (msg.value == 0) revert InvalidAmount();
        
        Vault storage vault = vaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();
        
        uint256 feeAmount = (msg.value * feeBps) / BPS_DENOMINATOR;
        uint256 depositAmount = msg.value - feeAmount;
        
        vault.balance += depositAmount;
        totalFeesCollected += feeAmount;
        
        emit Deposited(vaultId, msg.sender, depositAmount, feeAmount);
    }
    
    function withdraw(uint256 vaultId) external onlyVaultOwner(vaultId) {
        Vault storage vault = vaults[vaultId];
        if (!vault.isActive) revert VaultNotActive();
        
        if (vault.unlockTimestamp != 0 && block.timestamp < vault.unlockTimestamp) {
            revert VaultLocked();
        }
        
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
    
    function setVaultMetadata(uint256 vaultId, string calldata metadata) external onlyVaultOwner(vaultId) {
        vaults[vaultId].metadata = metadata;
        
        emit VaultMetadataUpdated(vaultId, metadata);
    }
    
    function collectFees() external onlyOwner {
        uint256 amount = totalFeesCollected;
        totalFeesCollected = 0;
        
        (bool success, ) = payable(owner).call{value: amount}("");
        if (!success) revert TransferFailed();
        
        emit FeeCollected(owner, amount);
    }
    
    function setFeeBps(uint256 newFeeBps) external onlyOwner {
        if (newFeeBps > MAX_FEE_BPS) revert InvalidFee();
        
        uint256 oldFee = feeBps;
        feeBps = newFeeBps;
        
        emit FeeUpdated(oldFee, newFeeBps);
    }
    
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidParameters();
        
        address oldOwner = owner;
        owner = newOwner;
        
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    function getUserVaults(address user) external view returns (uint256[] memory) {
        return userVaults[user];
    }
    
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
    
    function calculateDepositFee(uint256 amount) external view returns (uint256 fee, uint256 netDeposit) {
        fee = (amount * feeBps) / BPS_DENOMINATOR;
        netDeposit = amount - fee;
    }
}
