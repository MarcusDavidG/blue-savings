// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultMigrator
 * @notice Migrate vaults between contract versions
 */
contract VaultMigrator {
    address public oldVault;
    address public newVault;
    address public owner;

    mapping(uint256 => uint256) public migratedVaults; // old => new
    mapping(address => bool) public hasMigrated;

    event VaultMigrated(address indexed user, uint256 oldVaultId, uint256 newVaultId);

    constructor(address _oldVault, address _newVault) {
        oldVault = _oldVault;
        newVault = _newVault;
        owner = msg.sender;
    }

    function migrate(uint256 oldVaultId) external returns (uint256 newVaultId) {
        require(!hasMigrated[msg.sender], "Already migrated");

        // Get old vault data
        (bool success, bytes memory data) = oldVault.staticcall(
            abi.encodeWithSignature("getVaultDetails(uint256)", oldVaultId)
        );
        require(success, "Failed to get vault");

        (address vaultOwner,,,,,,, ) = abi.decode(
            data, 
            (address, uint256, uint256, uint256, bool, uint256, string, bool)
        );
        require(vaultOwner == msg.sender, "Not owner");

        // Create new vault (simplified - real impl would transfer funds)
        (success, data) = newVault.call(
            abi.encodeWithSignature(
                "createVault(uint256,uint256,string)",
                0, 0, "Migrated Vault"
            )
        );
        require(success, "Failed to create");

        newVaultId = abi.decode(data, (uint256));
        migratedVaults[oldVaultId] = newVaultId;
        hasMigrated[msg.sender] = true;

        emit VaultMigrated(msg.sender, oldVaultId, newVaultId);
    }

    /// @notice Batch migrate multiple vaults
    function batchMigrate(uint256[] calldata oldVaultIds) external returns (uint256[] memory newVaultIds) {
        newVaultIds = new uint256[](oldVaultIds.length);

        for (uint256 i = 0; i < oldVaultIds.length; i++) {
            newVaultIds[i] = this.migrate(oldVaultIds[i]);
        }
    }

    /// @notice Check if migration is possible for a vault
    function canMigrate(uint256 oldVaultId, address user) external view returns (bool) {
        if (hasMigrated[user]) return false;

        (bool success, bytes memory data) = oldVault.staticcall(
            abi.encodeWithSignature("getVaultDetails(uint256)", oldVaultId)
        );
        if (!success) return false;

        (address vaultOwner,,,,,,,) = abi.decode(
            data,
            (address, uint256, uint256, uint256, bool, uint256, string, bool)
        );

        return vaultOwner == user;
    }
}
