// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./interfaces/IERC20.sol";
import "./interfaces/IERC20Permit.sol";
import "./libraries/SafeERC20.sol";

/**
 * @title PermitDeposit
 * @notice Enables gas-less token approvals for deposits using EIP-2612 permits.
 * @dev This abstract contract provides internal functions to handle deposits where the user
 * has provided an off-chain signature (`permit`) to approve token spending, thus saving
 * a separate `approve` transaction.
 */
abstract contract PermitDeposit {
    using SafeERC20 for IERC20;

    /**
     * @notice Executes a token deposit using a permit signature for a gas-less approval.
     * @dev This function first calls `permit` on the token contract to grant approval via
     * the user's signature, and then immediately pulls the funds using `safeTransferFrom`.
     * It's designed to be called internally by other functions that handle user deposits.
     * @param token The address of the ERC20 token to be deposited.
     * @param amount The amount of tokens to deposit.
     * @param deadline The timestamp after which the permit signature is no longer valid.
     * @param v The recovery id of the signature.
     * @param r The r-value of the signature.
     * @param s The s-value of the signature.
     */
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

    /**
     * @notice Checks if a token contract supports the EIP-2612 `permit` function.
     * @dev It attempts to call the `DOMAIN_SEPARATOR` function, a standard part of the EIP-2612
     * interface. A successful call indicates that the token likely supports `permit`.
     * This is a view function and does not consume gas when called externally.
     * @param token The address of the token to check.
     * @return A boolean value, `true` if the token supports `permit`, otherwise `false`.
     */
    function _supportsPermit(address token) internal view returns (bool) {
        // Check for DOMAIN_SEPARATOR which indicates EIP-2612 support
        try IERC20Permit(token).DOMAIN_SEPARATOR() returns (bytes32) {
            return true;
        } catch {
            return false;
        }
    }
}
