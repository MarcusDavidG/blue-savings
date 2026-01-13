// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20.sol";
import "../libraries/SafeERC20.sol";
import "../utils/MerkleProof.sol";
import "../utils/BitMaps.sol";

/**
 * @title MerkleAirdrop
 * @notice Gas-efficient airdrop using merkle proofs
 */
contract MerkleAirdrop {
    using SafeERC20 for IERC20;
    using BitMaps for BitMaps.BitMap;

    IERC20 public immutable token;
    bytes32 public immutable merkleRoot;
    BitMaps.BitMap private _claimed;

    event Claimed(uint256 indexed index, address indexed account, uint256 amount);

    error AlreadyClaimed();
    error InvalidProof();

    constructor(address _token, bytes32 _merkleRoot) {
        token = IERC20(_token);
        merkleRoot = _merkleRoot;
    }

    function claim(uint256 index, address account, uint256 amount, bytes32[] calldata proof) external {
        if (_claimed.get(index)) revert AlreadyClaimed();

        bytes32 leaf = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verifyCalldata(proof, merkleRoot, leaf)) revert InvalidProof();

        _claimed.set(index);
        token.safeTransfer(account, amount);

        emit Claimed(index, account, amount);
    }

    function isClaimed(uint256 index) external view returns (bool) {
        return _claimed.get(index);
    }
}
