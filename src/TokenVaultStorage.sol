// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TokenVaultStorage
 * @notice Storage layout for token vault balances
 * @dev Tracks ERC-20 token balances per vault
 */
abstract contract TokenVaultStorage {
    /// @notice Mapping: vaultId => token => balance
    mapping(uint256 => mapping(address => uint256)) public vaultTokenBalances;

    /// @notice Mapping: vaultId => array of tokens deposited
    mapping(uint256 => address[]) public vaultTokenList;

    /// @notice Mapping: vaultId => token => index in vaultTokenList
    mapping(uint256 => mapping(address => uint256)) private _vaultTokenIndex;

    /// @notice Mapping: vaultId => token => has been deposited
    mapping(uint256 => mapping(address => bool)) public hasTokenDeposit;

    /// @notice Get token balance for a vault
    /// @param vaultId The vault ID
    /// @param token The token address
    /// @return The token balance
    function getVaultTokenBalance(uint256 vaultId, address token) external view returns (uint256) {
        return vaultTokenBalances[vaultId][token];
    }

    /// @notice Get all tokens deposited in a vault
    /// @param vaultId The vault ID
    /// @return Array of token addresses
    function getVaultTokens(uint256 vaultId) external view returns (address[] memory) {
        return vaultTokenList[vaultId];
    }

    /// @notice Get number of different tokens in a vault
    /// @param vaultId The vault ID
    /// @return Number of token types
    function getVaultTokenCount(uint256 vaultId) external view returns (uint256) {
        return vaultTokenList[vaultId].length;
    }

    /// @notice Internal: Add token to vault's token list if first deposit
    function _addTokenToVault(uint256 vaultId, address token) internal {
        if (!hasTokenDeposit[vaultId][token]) {
            hasTokenDeposit[vaultId][token] = true;
            _vaultTokenIndex[vaultId][token] = vaultTokenList[vaultId].length;
            vaultTokenList[vaultId].push(token);
        }
    }

    /// @notice Internal: Remove token from vault's token list
    function _removeTokenFromVault(uint256 vaultId, address token) internal {
        if (vaultTokenBalances[vaultId][token] == 0 && hasTokenDeposit[vaultId][token]) {
            hasTokenDeposit[vaultId][token] = false;

            uint256 index = _vaultTokenIndex[vaultId][token];
            uint256 lastIndex = vaultTokenList[vaultId].length - 1;

            if (index != lastIndex) {
                address lastToken = vaultTokenList[vaultId][lastIndex];
                vaultTokenList[vaultId][index] = lastToken;
                _vaultTokenIndex[vaultId][lastToken] = index;
            }

            vaultTokenList[vaultId].pop();
            delete _vaultTokenIndex[vaultId][token];
        }
    }
}
