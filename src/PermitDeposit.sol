// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC20Permit.sol";
import "./libraries/SafeERC20.sol";

/**
 * @title PermitDeposit
 * @notice Enable gasless token approvals using EIP-2612 permits
 * @dev Abstract contract for permit-based deposits
 */
abstract contract PermitDeposit {
    using SafeERC20 for IERC20;

    /// @notice Deposit with permit signature (gasless approval)
    /// @param token The token to deposit
    /// @param amount Amount to deposit
    /// @param deadline Permit deadline
    /// @param v Signature v
    /// @param r Signature r
    /// @param s Signature s
    function _permitAndPull(
        address token,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        IERC20Permit(token).permit(msg.sender, address(this), amount, deadline, v, r, s);
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }

    /// @notice Check if token supports permit
    /// @param token Token address to check
    /// @return True if token supports EIP-2612 permit
    function _supportsPermit(address token) internal view returns (bool) {
        // Check for DOMAIN_SEPARATOR which indicates EIP-2612 support
        try IERC20Permit(token).DOMAIN_SEPARATOR() returns (bytes32) {
            return true;
        } catch {
            return false;
        }
    }
}
