// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultDelegation
 * @notice Delegate vault management to another address
 */
contract VaultDelegation {
    mapping(uint256 => address) public vaultDelegate;
    mapping(address => mapping(address => bool)) public operatorApproval;

    event DelegateSet(uint256 indexed vaultId, address indexed delegate);
    event OperatorApproved(address indexed owner, address indexed operator, bool approved);

    function setDelegate(uint256 vaultId, address delegate) external {
        vaultDelegate[vaultId] = delegate;
        emit DelegateSet(vaultId, delegate);
    }

    function setOperatorApproval(address operator, bool approved) external {
        operatorApproval[msg.sender][operator] = approved;
        emit OperatorApproved(msg.sender, operator, approved);
    }

    function isApprovedOrOwner(address owner, address operator, uint256 vaultId) external view returns (bool) {
        return owner == operator || 
               vaultDelegate[vaultId] == operator || 
               operatorApproval[owner][operator];
    }

    function getDelegate(uint256 vaultId) external view returns (address) {
        return vaultDelegate[vaultId];
    }
}
