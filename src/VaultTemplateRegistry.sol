// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./VaultTemplateTypes.sol";

/**
 * @title VaultTemplateRegistry
 * @notice Registry for vault templates
 * @dev Manages creation and storage of vault templates
 */
contract VaultTemplateRegistry is VaultTemplateTypes {
    /// @notice Template counter
    uint256 public templateCounter;

    /// @notice Contract owner
    address public owner;

    /// @notice Mapping of template ID to template
    mapping(uint256 => VaultTemplate) public templates;

    /// @notice Templates by category
    mapping(TemplateCategory => uint256[]) public categoryTemplates;

    /// @notice Templates created by user
    mapping(address => uint256[]) public userTemplates;

    // Events
    event TemplateCreated(uint256 indexed templateId, string name, TemplateCategory category);
    event TemplateDeactivated(uint256 indexed templateId);
    event TemplateUsed(uint256 indexed templateId, address indexed user);

    // Errors
    error Unauthorized();
    error TemplateNotFound(uint256 templateId);
    error TemplateNotActive(uint256 templateId);
    error InvalidTemplateName();

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        _initializeDefaultTemplates();
    }

    /// @notice Create a new template
    function createTemplate(
        string calldata name,
        string calldata description,
        TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays,
        address suggestedToken
    ) external returns (uint256 templateId) {
        if (bytes(name).length == 0) revert InvalidTemplateName();

        templateId = templateCounter++;

        templates[templateId] = VaultTemplate({
            name: name,
            description: description,
            category: category,
            suggestedGoal: suggestedGoal,
            suggestedLockDays: suggestedLockDays,
            suggestedToken: suggestedToken,
            isActive: true,
            creator: msg.sender,
            usageCount: 0,
            createdAt: block.timestamp
        });

        categoryTemplates[category].push(templateId);
        userTemplates[msg.sender].push(templateId);

        emit TemplateCreated(templateId, name, category);
    }

    /// @notice Deactivate a template (owner or creator only)
    function deactivateTemplate(uint256 templateId) external {
        VaultTemplate storage template = templates[templateId];
        if (template.creator == address(0)) revert TemplateNotFound(templateId);
        if (msg.sender != owner && msg.sender != template.creator) revert Unauthorized();

        template.isActive = false;
        emit TemplateDeactivated(templateId);
    }

    /// @notice Record template usage
    function recordUsage(uint256 templateId) external {
        if (!templates[templateId].isActive) revert TemplateNotActive(templateId);
        templates[templateId].usageCount++;
        emit TemplateUsed(templateId, msg.sender);
    }

    /// @notice Get template by ID
    function getTemplate(uint256 templateId) external view returns (VaultTemplate memory) {
        return templates[templateId];
    }

    /// @notice Get templates by category
    function getTemplatesByCategory(TemplateCategory category) 
        external 
        view 
        returns (uint256[] memory) 
    {
        return categoryTemplates[category];
    }

    /// @notice Get user's created templates
    function getUserTemplates(address user) external view returns (uint256[] memory) {
        return userTemplates[user];
    }

    /// @notice Initialize default templates
    function _initializeDefaultTemplates() internal {
        // Emergency Fund - 3-6 months expenses
        _createDefaultTemplate(
            "Emergency Fund",
            "Build 3-6 months of living expenses for unexpected situations",
            TemplateCategory.Emergency,
            0, // Flexible goal
            0, // No lock
            address(0)
        );

        // Vacation Savings
        _createDefaultTemplate(
            "Vacation Fund",
            "Save for your dream vacation with a target date",
            TemplateCategory.Vacation,
            0,
            180, // 6 month suggested lock
            address(0)
        );

        // Retirement Savings
        _createDefaultTemplate(
            "Retirement Nest Egg",
            "Long-term retirement savings with extended lock",
            TemplateCategory.Retirement,
            0,
            365 * 5, // 5 year lock
            address(0)
        );
    }

    function _createDefaultTemplate(
        string memory name,
        string memory description,
        TemplateCategory category,
        uint256 suggestedGoal,
        uint256 suggestedLockDays,
        address suggestedToken
    ) internal {
        uint256 templateId = templateCounter++;

        templates[templateId] = VaultTemplate({
            name: name,
            description: description,
            category: category,
            suggestedGoal: suggestedGoal,
            suggestedLockDays: suggestedLockDays,
            suggestedToken: suggestedToken,
            isActive: true,
            creator: address(this),
            usageCount: 0,
            createdAt: block.timestamp
        });

        categoryTemplates[category].push(templateId);
    }
}
