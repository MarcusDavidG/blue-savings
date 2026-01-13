// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./IERC721.sol";

/**
 * @title IERC721Metadata
 * @notice ERC-721 metadata extension interface
 */
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
