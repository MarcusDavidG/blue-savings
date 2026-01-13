// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/yield/YieldManager.sol";
import "../src/interfaces/IYieldAdapter.sol";

contract MockYieldAdapter is IYieldAdapter {
    string public _name;
    mapping(address => bool) public _supported;
    mapping(address => uint256) public _apy;
    mapping(address => uint256) public _balance;

    constructor(string memory name_) {
        _name = name_;
    }

    function setSupported(address token, bool supported) external {
        _supported[token] = supported;
    }

    function setAPY(address token, uint256 apy) external {
        _apy[token] = apy;
    }

    function setBalance(address token, uint256 balance) external {
        _balance[token] = balance;
    }

    function deposit(address, uint256) external pure override returns (uint256) {
        return 0;
    }

    function withdraw(address, uint256) external pure override returns (uint256) {
        return 0;
    }

    function getBalance(address token, address) external view override returns (uint256) {
        return _balance[token];
    }

    function getAPY(address token) external view override returns (uint256) {
        return _apy[token];
    }

    function isSupported(address token) external view override returns (bool) {
        return _supported[token];
    }

    function protocolName() external view override returns (string memory) {
        return _name;
    }
}

contract YieldManagerTest is Test {
    YieldManager public manager;
    MockYieldAdapter public aaveAdapter;
    MockYieldAdapter public compoundAdapter;

    address public vault;
    address public usdc;

    function setUp() public {
        vault = makeAddr("vault");
        usdc = makeAddr("usdc");

        manager = new YieldManager(vault);
        aaveAdapter = new MockYieldAdapter("Aave V3");
        compoundAdapter = new MockYieldAdapter("Compound V3");
    }

    function test_AddAdapter() public {
        manager.addAdapter(address(aaveAdapter));

        address[] memory adapters = manager.getAdapters();
        assertEq(adapters.length, 1);
        assertEq(adapters[0], address(aaveAdapter));
    }

    function test_RemoveAdapter() public {
        manager.addAdapter(address(aaveAdapter));
        manager.addAdapter(address(compoundAdapter));

        manager.removeAdapter(address(aaveAdapter));

        address[] memory adapters = manager.getAdapters();
        assertEq(adapters.length, 1);
        assertEq(adapters[0], address(compoundAdapter));
    }

    function test_SetPreferredAdapter() public {
        manager.addAdapter(address(aaveAdapter));
        manager.setPreferredAdapter(usdc, address(aaveAdapter));

        assertEq(manager.preferredAdapter(usdc), address(aaveAdapter));
    }

    function test_GetBestAPY() public {
        aaveAdapter.setSupported(usdc, true);
        aaveAdapter.setAPY(usdc, 500); // 5%

        compoundAdapter.setSupported(usdc, true);
        compoundAdapter.setAPY(usdc, 700); // 7%

        manager.addAdapter(address(aaveAdapter));
        manager.addAdapter(address(compoundAdapter));

        (address bestAdapter, uint256 bestApy) = manager.getBestAPY(usdc);

        assertEq(bestAdapter, address(compoundAdapter));
        assertEq(bestApy, 700);
    }

    function test_GetTotalBalance() public {
        aaveAdapter.setSupported(usdc, true);
        aaveAdapter.setBalance(usdc, 1000e6);

        compoundAdapter.setSupported(usdc, true);
        compoundAdapter.setBalance(usdc, 500e6);

        manager.addAdapter(address(aaveAdapter));
        manager.addAdapter(address(compoundAdapter));

        uint256 total = manager.getTotalBalance(usdc);
        assertEq(total, 1500e6);
    }
}
