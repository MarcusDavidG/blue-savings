// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20Permit.sol";

/**
 * @title SelfPermit
 * @notice Permit helper for gasless approvals
 */
abstract contract SelfPermit {
    function selfPermit(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        IERC20Permit(token).permit(msg.sender, address(this), value, deadline, v, r, s);
    }

    function selfPermitIfNecessary(
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        if (IERC20Permit(token).allowance(msg.sender, address(this)) < value) {
            IERC20Permit(token).permit(msg.sender, address(this), value, deadline, v, r, s);
        }
    }
}
