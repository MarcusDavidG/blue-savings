// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SecurityContact
 * @author BlueSavings Team
 * @notice Security contact information for vulnerability disclosure
 * @custom:security-contact security@bluesavings.xyz
 */
abstract contract SecurityContact {
    /// @notice Security contact email
    string public constant SECURITY_CONTACT = "security@bluesavings.xyz";

    /// @notice Bug bounty program URL
    string public constant BUG_BOUNTY_URL = "https://immunefi.com/bounty/bluesavings";

    /// @notice Get security contact info
    function securityInfo() external pure returns (string memory contact, string memory bounty) {
        return (SECURITY_CONTACT, BUG_BOUNTY_URL);
    }
}
