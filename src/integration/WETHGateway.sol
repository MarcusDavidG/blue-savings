// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IWETH
 * @notice Wrapped ETH interface
 */
interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function balanceOf(address owner) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

/**
 * @title WETHGateway
 * @notice Gateway for ETH/WETH conversions in vault deposits
 */
contract WETHGateway {
    IWETH public immutable weth;

    event DepositedETH(address indexed user, uint256 amount);
    event WithdrawnETH(address indexed user, uint256 amount);

    error TransferFailed();

    constructor(address _weth) {
        weth = IWETH(_weth);
    }

    /// @notice Deposit ETH and receive WETH
    function depositETH() external payable {
        weth.deposit{value: msg.value}();
        require(weth.transfer(msg.sender, msg.value), "Transfer failed");
        emit DepositedETH(msg.sender, msg.value);
    }

    /// @notice Withdraw WETH and receive ETH
    function withdrawETH(uint256 amount) external {
        require(weth.balanceOf(msg.sender) >= amount, "Insufficient WETH");
        // Note: Caller must approve this contract first
        weth.withdraw(amount);
        (bool success,) = msg.sender.call{value: amount}("");
        if (!success) revert TransferFailed();
        emit WithdrawnETH(msg.sender, amount);
    }

    /// @notice Deposit ETH directly to a vault
    function depositETHToVault(address vault, uint256 vaultId) external payable {
        weth.deposit{value: msg.value}();
        weth.transfer(vault, msg.value);
        // Vault would need to handle the deposit
        emit DepositedETH(vault, msg.value);
    }

    receive() external payable {}
}
