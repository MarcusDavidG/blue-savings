// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title BeforeDeposit
 * @notice Hook interface for pre-deposit validation
 */
interface IBeforeDepositHook {
    function beforeDeposit(address user, uint256 vaultId, uint256 amount) external returns (bool);
}

abstract contract BeforeDepositHook {
    IBeforeDepositHook public beforeDepositHook;

    function _setBeforeDepositHook(address hook) internal {
        beforeDepositHook = IBeforeDepositHook(hook);
    }

    function _beforeDeposit(address user, uint256 vaultId, uint256 amount) internal {
        if (address(beforeDepositHook) != address(0)) {
            require(beforeDepositHook.beforeDeposit(user, vaultId, amount), "Hook rejected");
        }
    }
}
