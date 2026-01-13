// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IERC721Receiver
 * @notice Interface for contracts that can receive ERC-721 tokens
 */
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
