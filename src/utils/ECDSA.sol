// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ECDSA
 * @notice Elliptic Curve Digital Signature Algorithm utilities
 */
library ECDSA {
    error ECDSAInvalidSignature();
    error ECDSAInvalidSignatureLength(uint256 length);
    error ECDSAInvalidSignatureS(bytes32 s);

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, bool) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        }
        return (address(0), false);
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, bool valid) = tryRecover(hash, signature);
        if (!valid) revert ECDSAInvalidSignature();
        return recovered;
    }

    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, bool) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), false);
        }
        address signer = ecrecover(hash, v, r, s);
        return (signer, signer != address(0));
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, bool valid) = tryRecover(hash, v, r, s);
        if (!valid) revert ECDSAInvalidSignature();
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}
