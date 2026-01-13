// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title VaultViewer
 * @notice Multicall view functions for frontend
 */
contract VaultViewer {
    struct VaultInfo {
        uint256 vaultId;
        address owner;
        uint256 balance;
        uint256 goalAmount;
        uint256 unlockTimestamp;
        bool isActive;
        bool canWithdraw;
    }

    function getVaultsBatch(address vault, uint256[] calldata vaultIds) 
        external 
        view 
        returns (VaultInfo[] memory infos) 
    {
        infos = new VaultInfo[](vaultIds.length);
        
        for (uint256 i = 0; i < vaultIds.length; i++) {
            (bool success, bytes memory data) = vault.staticcall(
                abi.encodeWithSignature("getVaultDetails(uint256)", vaultIds[i])
            );
            
            if (success && data.length > 0) {
                (
                    address owner,
                    uint256 balance,
                    uint256 goalAmount,
                    uint256 unlockTimestamp,
                    bool isActive,
                    ,
                    ,
                    bool canWithdraw
                ) = abi.decode(data, (address, uint256, uint256, uint256, bool, uint256, string, bool));
                
                infos[i] = VaultInfo({
                    vaultId: vaultIds[i],
                    owner: owner,
                    balance: balance,
                    goalAmount: goalAmount,
                    unlockTimestamp: unlockTimestamp,
                    isActive: isActive,
                    canWithdraw: canWithdraw
                });
            }
        }
    }
}
