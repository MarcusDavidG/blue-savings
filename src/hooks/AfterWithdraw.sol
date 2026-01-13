// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title AfterWithdraw
 * @notice Hook interface for post-withdraw actions
 */
interface IAfterWithdrawHook {
    function afterWithdraw(address user, uint256 vaultId, uint256 amount) external;
}

abstract contract AfterWithdrawHook {
    IAfterWithdrawHook public afterWithdrawHook;

    function _setAfterWithdrawHook(address hook) internal {
        afterWithdrawHook = IAfterWithdrawHook(hook);
    }

    function _afterWithdraw(address user, uint256 vaultId, uint256 amount) internal {
        if (address(afterWithdrawHook) != address(0)) {
            afterWithdrawHook.afterWithdraw(user, vaultId, amount);
        }
    }
}
