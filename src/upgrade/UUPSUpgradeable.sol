// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title UUPSUpgradeable
 * @notice UUPS upgrade pattern base contract
 */
abstract contract UUPSUpgradeable {
    address private _implementation;

    event Upgraded(address indexed implementation);

    error InvalidImplementation();
    error UnauthorizedUpgrade();

    function _authorizeUpgrade(address newImplementation) internal virtual;

    function upgradeTo(address newImplementation) external {
        _authorizeUpgrade(newImplementation);
        _setImplementation(newImplementation);
    }

    function _setImplementation(address newImplementation) private {
        if (newImplementation.code.length == 0) revert InvalidImplementation();
        _implementation = newImplementation;
        emit Upgraded(newImplementation);
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }
}
