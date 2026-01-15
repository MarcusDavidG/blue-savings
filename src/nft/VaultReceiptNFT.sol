// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC721Metadata.sol";

/**
 * @title VaultReceiptNFT
 * @notice NFT receipts for savings vault deposits
 * @dev Mints NFT when vault is created, burns on full withdrawal
 */
contract VaultReceiptNFT is IERC721Metadata {
    /// @notice Token name
    string public constant override name = "BlueSavings Vault Receipt";

    /// @notice Token symbol
    string public constant override symbol = "BSVR";

    /// @notice Total supply
    uint256 public totalSupply;

    /// @notice Savings vault contract
    address public savingsVault;

    /// @notice Contract owner
    address public owner;

    /// @notice Token ID to owner
    mapping(uint256 => address) private _owners;

    /// @notice Owner to balance
    mapping(address => uint256) private _balances;

    /// @notice Token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    /// @notice Owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /// @notice Token ID to vault metadata
    mapping(uint256 => VaultMetadata) public vaultMetadata;

    struct VaultMetadata {
        uint256 vaultId;
        address token;
        uint256 initialDeposit;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        uint256 createdAt;
        string vaultName;
        uint8 tier; // 0=Bronze, 1=Silver, 2=Gold, 3=Platinum
    }

    /// @notice Achievement thresholds for tier upgrades
    uint256 public constant SILVER_THRESHOLD = 1 ether;
    uint256 public constant GOLD_THRESHOLD = 10 ether;
    uint256 public constant PLATINUM_THRESHOLD = 100 ether;

    // Errors
    error Unauthorized();
    error InvalidToken();
    error NotOwnerOrApproved();
    error TransferToZeroAddress();
    error InvalidReceiver();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyVault() {
        if (msg.sender != savingsVault) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Set the savings vault address
    function setSavingsVault(address _vault) external onlyOwner {
        savingsVault = _vault;
    }

    /// @notice Mint NFT receipt for vault
    function mint(
        address to,
        uint256 vaultId,
        address token,
        uint256 initialDeposit,
        uint256 goalAmount,
        uint256 unlockTimestamp
    ) external onlyVault returns (uint256 tokenId) {
        tokenId = vaultId; // Use vault ID as token ID

        _owners[tokenId] = to;
        _balances[to]++;
        totalSupply++;

        vaultMetadata[tokenId] = VaultMetadata({
            vaultId: vaultId,
            token: token,
            initialDeposit: initialDeposit,
            goalAmount: goalAmount,
            unlockTimestamp: unlockTimestamp,
            createdAt: block.timestamp,
            vaultName: "",
            tier: _calculateTier(goalAmount)
        });

        emit Transfer(address(0), to, tokenId);
    }

    /// @notice Burn NFT when vault is fully withdrawn
    function burn(uint256 tokenId) external onlyVault {
        address tokenOwner = _owners[tokenId];
        if (tokenOwner == address(0)) revert InvalidToken();

        _balances[tokenOwner]--;
        delete _owners[tokenId];
        delete _tokenApprovals[tokenId];
        totalSupply--;

        emit Transfer(tokenOwner, address(0), tokenId);
    }

    /// @notice Get balance of owner
    function balanceOf(address ownerAddr) external view override returns (uint256) {
        return _balances[ownerAddr];
    }

    /// @notice Get owner of token
    function ownerOf(uint256 tokenId) external view override returns (address) {
        address tokenOwner = _owners[tokenId];
        if (tokenOwner == address(0)) revert InvalidToken();
        return tokenOwner;
    }

    /// @notice Get token URI with vault data
    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        if (_owners[tokenId] == address(0)) revert InvalidToken();
        // Return base64 encoded JSON metadata
        return _generateTokenURI(tokenId);
    }

    /// @notice Approve token transfer
    function approve(address to, uint256 tokenId) external override {
        address tokenOwner = _owners[tokenId];
        if (msg.sender != tokenOwner && !_operatorApprovals[tokenOwner][msg.sender]) {
            revert NotOwnerOrApproved();
        }
        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    /// @notice Get approved address
    function getApproved(uint256 tokenId) external view override returns (address) {
        if (_owners[tokenId] == address(0)) revert InvalidToken();
        return _tokenApprovals[tokenId];
    }

    /// @notice Set operator approval
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Check operator approval
    function isApprovedForAll(address ownerAddr, address operator) external view override returns (bool) {
        return _operatorApprovals[ownerAddr][operator];
    }

    /// @notice Transfer token
    function transferFrom(address from, address to, uint256 tokenId) public override {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) revert NotOwnerOrApproved();
        if (to == address(0)) revert TransferToZeroAddress();

        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    /// @notice Safe transfer
    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /// @notice Safe transfer with data
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory) public override {
        transferFrom(from, to, tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = _owners[tokenId];
        return (spender == tokenOwner || 
                _tokenApprovals[tokenId] == spender || 
                _operatorApprovals[tokenOwner][spender]);
    }

    function _generateTokenURI(uint256 tokenId) internal view returns (string memory) {
        VaultMetadata memory meta = vaultMetadata[tokenId];
        // Simplified - in production would generate full JSON
        return string(abi.encodePacked(
            "data:application/json,{\"name\":\"Vault #",
            _toString(meta.vaultId),
            "\",\"description\":\"BlueSavings Vault Receipt\"}"
        ));
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /// @notice Calculate tier based on amount
    function _calculateTier(uint256 amount) internal pure returns (uint8) {
        if (amount >= PLATINUM_THRESHOLD) return 3;
        if (amount >= GOLD_THRESHOLD) return 2;
        if (amount >= SILVER_THRESHOLD) return 1;
        return 0;
    }

    /// @notice Get tier name
    function getTierName(uint8 tier) external pure returns (string memory) {
        if (tier == 3) return "Platinum";
        if (tier == 2) return "Gold";
        if (tier == 1) return "Silver";
        return "Bronze";
    }

    /// @notice Update vault name
    function setVaultName(uint256 tokenId, string calldata newName) external {
        if (_owners[tokenId] != msg.sender) revert NotOwnerOrApproved();
        vaultMetadata[tokenId].vaultName = newName;
    }
}
