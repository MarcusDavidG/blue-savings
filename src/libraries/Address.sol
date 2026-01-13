// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Address
 * @notice Utility library for address operations
 * @dev Provides functions for contract detection and safe calls
 */
library Address {
    /// @notice Thrown when call to non-contract address fails
    error AddressEmptyCode(address target);

    /// @notice Thrown when contract has insufficient balance
    error AddressInsufficientBalance(address account);

    /// @notice Thrown when a low-level call fails
    error FailedInnerCall();

    /// @notice Check if an address is a contract
    /// @param account The address to check
    /// @return True if address has code (is a contract)
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }

    /// @notice Send ETH to an address with gas stipend
    /// @param recipient The address to send to
    /// @param amount The amount of ETH to send
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }

        (bool success,) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }

    /// @notice Perform a low-level call
    /// @param target The target address
    /// @param data The calldata
    /// @return The return data from the call
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }

    /// @notice Perform a low-level call with ETH value
    /// @param target The target address
    /// @param data The calldata
    /// @param value The ETH value to send
    /// @return The return data from the call
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }

    /// @notice Verify call result and handle revert
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && !isContract(target)) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }

    /// @notice Bubble up revert reason
    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
