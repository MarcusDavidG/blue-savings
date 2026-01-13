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
}
