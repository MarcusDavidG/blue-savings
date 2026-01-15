// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Whitelist
 * @notice Address whitelist for restricted access
 */
contract Whitelist {
    mapping(address => bool) public isWhitelisted;
    address public owner;

    event AddressWhitelisted(address indexed account);
    event AddressRemoved(address indexed account);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyWhitelisted() {
        require(isWhitelisted[msg.sender], "Not whitelisted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addToWhitelist(address account) external onlyOwner {
        isWhitelisted[account] = true;
        emit AddressWhitelisted(account);
    }

    function removeFromWhitelist(address account) external onlyOwner {
        isWhitelisted[account] = false;
        emit AddressRemoved(account);
    }

    function addBatch(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            isWhitelisted[accounts[i]] = true;
            emit AddressWhitelisted(accounts[i]);
        }
    }
}
