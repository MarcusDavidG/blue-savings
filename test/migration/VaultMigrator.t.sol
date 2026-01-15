// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/migration/VaultMigrator.sol";

contract VaultMigratorTest is Test {
    VaultMigrator public migrator;
    address public oldVault;
    address public newVault;

    function setUp() public {
        oldVault = makeAddr("oldVault");
        newVault = makeAddr("newVault");
        migrator = new VaultMigrator(oldVault, newVault);
    }

    function test_Constructor() public view {
        assertEq(migrator.oldVault(), oldVault);
        assertEq(migrator.newVault(), newVault);
        assertEq(migrator.owner(), address(this));
    }

    function test_MigratedMapping() public view {
        assertEq(migrator.migratedVaults(0), 0);
    }
}
