// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultFactory
 * @notice Factory for deploying user vaults
 */
contract VaultFactory {
    address public implementation;
    address public owner;

    address[] public deployedVaults;
    mapping(address => address[]) public userVaults;

    event VaultDeployed(address indexed vault, address indexed owner);

    constructor(address _implementation) {
        implementation = _implementation;
        owner = msg.sender;
    }

    function deployVault(bytes32 salt) external returns (address vault) {
        bytes memory bytecode = _getCreationBytecode();
        
        assembly {
            vault := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }

        require(vault != address(0), "Deploy failed");

        deployedVaults.push(vault);
        userVaults[msg.sender].push(vault);

        emit VaultDeployed(vault, msg.sender);
    }

    function computeAddress(bytes32 salt) external view returns (address) {
        bytes memory bytecode = _getCreationBytecode();
        bytes32 hash = keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(bytecode)
        ));
        return address(uint160(uint256(hash)));
    }

    function _getCreationBytecode() internal view returns (bytes memory) {
        return abi.encodePacked(
            type(MinimalProxy).creationCode,
            uint256(uint160(implementation))
        );
    }

    function getDeployedCount() external view returns (uint256) {
        return deployedVaults.length;
    }

    function getUserVaults(address user) external view returns (address[] memory) {
        return userVaults[user];
    }
}

contract MinimalProxy {
    constructor() {
        assembly {
            sstore(0, caller())
        }
    }
}
