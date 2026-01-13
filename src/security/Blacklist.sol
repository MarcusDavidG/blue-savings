// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Blacklist
 * @notice Address blacklisting for compliance
 */
contract Blacklist {
    address public owner;
    mapping(address => bool) public isBlacklisted;
    address[] public blacklistedAddresses;

    event AddressBlacklisted(address indexed account);
    event AddressUnblacklisted(address indexed account);

    error Blacklisted(address account);

    modifier notBlacklisted(address account) {
        if (isBlacklisted[account]) revert Blacklisted(account);
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function blacklist(address account) external {
        require(msg.sender == owner, "Not owner");
        require(!isBlacklisted[account], "Already blacklisted");
        isBlacklisted[account] = true;
        blacklistedAddresses.push(account);
        emit AddressBlacklisted(account);
    }

    function unblacklist(address account) external {
        require(msg.sender == owner, "Not owner");
        require(isBlacklisted[account], "Not blacklisted");
        isBlacklisted[account] = false;
        emit AddressUnblacklisted(account);
    }

    function getBlacklistedCount() external view returns (uint256) {
        return blacklistedAddresses.length;
    }
}
