// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Nonces
 * @notice Nonce management for replay protection
 */
abstract contract Nonces {
    mapping(address => uint256) private _nonces;

    error InvalidNonce(address account, uint256 currentNonce, uint256 providedNonce);

    function nonces(address owner) public view returns (uint256) {
        return _nonces[owner];
    }

    function _useNonce(address owner) internal returns (uint256) {
        unchecked {
            return _nonces[owner]++;
        }
    }

    function _useCheckedNonce(address owner, uint256 nonce) internal {
        uint256 current = _nonces[owner];
        if (nonce != current) revert InvalidNonce(owner, current, nonce);
        unchecked {
            _nonces[owner]++;
        }
    }
}
