// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IERC20Permit
 * @notice ERC-2612 permit interface for gasless approvals
 * @dev Allows approvals via signatures instead of transactions
 */
interface IERC20Permit {
    /// @notice Approve via signature (EIP-2612)
    /// @param owner Token owner
    /// @param spender Spender to approve
    /// @param value Amount to approve
    /// @param deadline Signature expiry timestamp
    /// @param v Signature v component
    /// @param r Signature r component
    /// @param s Signature s component
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /// @notice Returns current nonce for an address
    /// @param owner Address to query nonce for
    function nonces(address owner) external view returns (uint256);

    /// @notice Returns the domain separator for EIP-712
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
