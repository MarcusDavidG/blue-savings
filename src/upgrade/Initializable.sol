// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Initializable
 * @notice Initialization guard for upgradeable contracts
 */
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;

    event Initialized(uint8 version);

    error AlreadyInitialized();
    error NotInitializing();

    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall && _initialized >= 1) revert AlreadyInitialized();
        
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier onlyInitializing() {
        if (!_initializing) revert NotInitializing();
        _;
    }

    function _disableInitializers() internal {
        _initialized = type(uint8).max;
    }
}
