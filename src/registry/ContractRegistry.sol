// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ContractRegistry
 * @notice Central registry for protocol contracts
 */
contract ContractRegistry {
    address public owner;
    mapping(bytes32 => address) public contracts;
    bytes32[] public contractIds;

    event ContractRegistered(bytes32 indexed id, address indexed contractAddress);
    event ContractUpdated(bytes32 indexed id, address indexed oldAddress, address indexed newAddress);

    constructor() {
        owner = msg.sender;
    }

    function register(bytes32 id, address contractAddress) external {
        require(msg.sender == owner, "Not owner");
        require(contractAddress != address(0), "Zero address");

        if (contracts[id] == address(0)) {
            contractIds.push(id);
            emit ContractRegistered(id, contractAddress);
        } else {
            emit ContractUpdated(id, contracts[id], contractAddress);
        }

        contracts[id] = contractAddress;
    }

    function get(bytes32 id) external view returns (address) {
        return contracts[id];
    }

    function getContractCount() external view returns (uint256) {
        return contractIds.length;
    }
}
