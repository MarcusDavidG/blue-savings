// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../interfaces/IERC20Permit.sol";

/**
 * @title SafeERC20
 * @notice Safe wrapper for ERC-20 operations
 * @dev Handles non-standard tokens that don't return booleans
 */
library SafeERC20 {
    /// @notice Thrown when a token transfer fails
    error SafeERC20FailedOperation(address token);

    /// @notice Thrown when a token operation fails with a decrease below zero
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);

    /// @notice Safely transfers tokens
    /// @param token The token to transfer
    /// @param to The recipient
    /// @param value The amount to transfer
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }

    /// @notice Safely transfers tokens from an address
    /// @param token The token to transfer
    /// @param from The sender
    /// @param to The recipient
    /// @param value The amount to transfer
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }

    /// @notice Safely increases allowance
    /// @param token The token
    /// @param spender The spender
    /// @param value The amount to increase by
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }

    /// @notice Safely decreases allowance
    /// @param token The token
    /// @param spender The spender
    /// @param requestedDecrease The amount to decrease by
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        uint256 currentAllowance = token.allowance(address(this), spender);
        if (currentAllowance < requestedDecrease) {
            revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
        }
        unchecked {
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }

    /// @notice Force approve regardless of current allowance
    /// @param token The token
    /// @param spender The spender
    /// @param value The amount to approve
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /// @notice Call a token with optional return handling
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        (bool success, bytes memory returndata) = address(token).call(data);
        if (!success || (returndata.length != 0 && !abi.decode(returndata, (bool)))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }

    /// @notice Call and return success status
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool)));
    }
}
