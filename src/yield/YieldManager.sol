// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IYieldAdapter.sol";
import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";

/**
 * @title YieldManager
 * @notice Manages yield strategies for vault deposits
 * @dev Routes deposits to optimal yield protocols
 */
contract YieldManager {
    using SafeERC20 for IERC20;

    /// @notice Available yield adapters
    address[] public adapters;

    /// @notice Mapping of adapter address to index
    mapping(address => uint256) public adapterIndex;

    /// @notice Mapping of token to preferred adapter
    mapping(address => address) public preferredAdapter;

    /// @notice Contract owner
    address public owner;

    /// @notice Vault contract
    address public vault;

    // Events
    event AdapterAdded(address indexed adapter, string protocol);
    event AdapterRemoved(address indexed adapter);
    event PreferredAdapterSet(address indexed token, address indexed adapter);
    event YieldDeposited(address indexed token, address indexed adapter, uint256 amount);
    event YieldWithdrawn(address indexed token, address indexed adapter, uint256 amount);

    // Errors
    error Unauthorized();
    error AdapterNotFound();
    error NoAdapterForToken();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyVault() {
        if (msg.sender != vault) revert Unauthorized();
        _;
    }

    constructor(address _vault) {
        owner = msg.sender;
        vault = _vault;
    }

    /// @notice Add a yield adapter
    function addAdapter(address adapter) external onlyOwner {
        adapterIndex[adapter] = adapters.length;
        adapters.push(adapter);
        emit AdapterAdded(adapter, IYieldAdapter(adapter).protocolName());
    }

    /// @notice Remove a yield adapter
    function removeAdapter(address adapter) external onlyOwner {
        uint256 index = adapterIndex[adapter];
        uint256 lastIndex = adapters.length - 1;

        if (index != lastIndex) {
            address lastAdapter = adapters[lastIndex];
            adapters[index] = lastAdapter;
            adapterIndex[lastAdapter] = index;
        }

        adapters.pop();
        delete adapterIndex[adapter];
        emit AdapterRemoved(adapter);
    }

    /// @notice Set preferred adapter for a token
    function setPreferredAdapter(address token, address adapter) external onlyOwner {
        preferredAdapter[token] = adapter;
        emit PreferredAdapterSet(token, adapter);
    }

    /// @notice Deposit tokens into yield protocol
    function depositToYield(address token, uint256 amount) external onlyVault {
        address adapter = preferredAdapter[token];
        if (adapter == address(0)) revert NoAdapterForToken();

        IERC20(token).safeTransferFrom(vault, address(this), amount);
        IERC20(token).approve(adapter, amount);

        IYieldAdapter(adapter).deposit(token, amount);
        emit YieldDeposited(token, adapter, amount);
    }

    /// @notice Withdraw tokens from yield protocol
    function withdrawFromYield(address token, uint256 amount) external onlyVault {
        address adapter = preferredAdapter[token];
        if (adapter == address(0)) revert NoAdapterForToken();

        IYieldAdapter(adapter).withdraw(token, amount);
        emit YieldWithdrawn(token, adapter, amount);
    }

    /// @notice Get total balance across all adapters for a token
    function getTotalBalance(address token) external view returns (uint256 total) {
        for (uint256 i = 0; i < adapters.length; i++) {
            if (IYieldAdapter(adapters[i]).isSupported(token)) {
                total += IYieldAdapter(adapters[i]).getBalance(token, address(this));
            }
        }
    }

    /// @notice Get best APY for a token
    function getBestAPY(address token) external view returns (address bestAdapter, uint256 bestApy) {
        for (uint256 i = 0; i < adapters.length; i++) {
            if (IYieldAdapter(adapters[i]).isSupported(token)) {
                uint256 apy = IYieldAdapter(adapters[i]).getAPY(token);
                if (apy > bestApy) {
                    bestApy = apy;
                    bestAdapter = adapters[i];
                }
            }
        }
    }

    /// @notice Get all adapters
    function getAdapters() external view returns (address[] memory) {
        return adapters;
    }
}
