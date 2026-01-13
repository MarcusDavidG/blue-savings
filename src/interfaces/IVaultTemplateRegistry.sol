// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../VaultTemplateTypes.sol";

/**
 * @title IVaultTemplateRegistry
 * @notice Interface for VaultTemplateRegistry
 */
interface IVaultTemplateRegistry {
    function createTemplate(
        string calldata name,
        string calldata description,
        VaultTemplateTypes.TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays,
        address suggestedToken
    ) external returns (uint256 templateId);

    function deactivateTemplate(uint256 templateId) external;

    function recordUsage(uint256 templateId) external;

    function getTemplate(uint256 templateId) 
        external 
        view 
        returns (VaultTemplateTypes.VaultTemplate memory);

    function getTemplatesByCategory(VaultTemplateTypes.TemplateCategory category) 
        external 
        view 
        returns (uint256[] memory);

    function getUserTemplates(address user) external view returns (uint256[] memory);
}
