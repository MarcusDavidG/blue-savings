// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC20.sol";

/**
 * @title IERC20Metadata
 * @notice Extended ERC-20 interface with metadata functions
 * @dev Adds name, symbol, and decimals to the base IERC20 interface
 */
interface IERC20Metadata is IERC20 {
    /// @notice Returns the name of the token
    function name() external view returns (string memory);

    /// @notice Returns the symbol of the token
    function symbol() external view returns (string memory);

    /// @notice Returns the number of decimals for display
    function decimals() external view returns (uint8);
}
