// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/yield/YieldManager.sol";
import "../../src/mocks/MockERC20.sol";
import "../../src/mocks/MockYieldAdapter.sol";

contract YieldManagerTest is Test {
    YieldManager public manager;
    MockERC20 public token;
    MockYieldAdapter public adapter;
    address public vault;

    function setUp() public {
        vault = makeAddr("vault");
        manager = new YieldManager(vault);
        token = new MockERC20("Test", "TST", 18);
        adapter = new MockYieldAdapter();
        adapter.setSupported(address(token), true);

        manager.addAdapter(address(adapter));
        manager.setPreferredAdapter(address(token), address(adapter));
    }

    function test_AddAdapter() public {
        MockYieldAdapter newAdapter = new MockYieldAdapter();
        manager.addAdapter(address(newAdapter));

        address[] memory adapters = manager.getAdapters();
        assertEq(adapters.length, 2);
    }

    function test_SelectBestAdapter() public view {
        address best = manager.selectBestAdapter(address(token));
        assertEq(best, address(adapter));
    }

    function test_Pause() public {
        manager.pause();
        assertTrue(manager.paused());
    }

    function test_Unpause() public {
        manager.pause();
        manager.unpause();
        assertFalse(manager.paused());
    }
}
