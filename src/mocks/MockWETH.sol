// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./MockERC20.sol";

/**
 * @title MockWETH
 * @notice Mock Wrapped ETH token for testing
 * @dev 18 decimals, includes deposit/withdraw for WETH behavior
 */
contract MockWETH is MockERC20 {
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    constructor() MockERC20("Wrapped Ether", "WETH", 18) {}

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 wad) external {
        _burn(msg.sender, wad);
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }

    function _mint(address to, uint256 amount) internal {
        // Direct state modification for mock
        assembly {
            mstore(0, to)
            mstore(32, 3) // _balances slot
            let slot := keccak256(0, 64)
            sstore(slot, add(sload(slot), amount))
            // Update total supply (slot 3)
            sstore(3, add(sload(3), amount))
        }
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        assembly {
            mstore(0, from)
            mstore(32, 3) // _balances slot
            let slot := keccak256(0, 64)
            let balance := sload(slot)
            if lt(balance, amount) { revert(0, 0) }
            sstore(slot, sub(balance, amount))
            sstore(3, sub(sload(3), amount))
        }
        emit Transfer(from, address(0), amount);
    }
}
