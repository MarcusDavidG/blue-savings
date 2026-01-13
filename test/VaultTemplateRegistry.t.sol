// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/VaultTemplateRegistry.sol";

contract VaultTemplateRegistryTest is Test {
    VaultTemplateRegistry public registry;

    address public user1;

    function setUp() public {
        user1 = makeAddr("user1");
        registry = new VaultTemplateRegistry();
    }

    function test_DefaultTemplatesCreated() public view {
        // Should have 3 default templates
        assertEq(registry.templateCounter(), 3);

        VaultTemplateTypes.VaultTemplate memory template = registry.getTemplate(0);
        assertEq(template.name, "Emergency Fund");
        assertTrue(template.isActive);
    }

    function test_CreateCustomTemplate() public {
        vm.prank(user1);
        uint256 templateId = registry.createTemplate(
            "My Custom Template",
            "A custom savings template",
            VaultTemplateTypes.TemplateCategory.Custom,
            1000e18,
            90,
            address(0)
        );

        assertEq(templateId, 3); // After 3 defaults

        VaultTemplateTypes.VaultTemplate memory template = registry.getTemplate(templateId);
        assertEq(template.name, "My Custom Template");
        assertEq(template.creator, user1);
        assertTrue(template.isActive);
    }

    function test_DeactivateTemplate() public {
        vm.prank(user1);
        uint256 templateId = registry.createTemplate(
            "Test Template",
            "Test",
            VaultTemplateTypes.TemplateCategory.Custom,
            0,
            0,
            address(0)
        );

        vm.prank(user1);
        registry.deactivateTemplate(templateId);

        VaultTemplateTypes.VaultTemplate memory template = registry.getTemplate(templateId);
        assertFalse(template.isActive);
    }

    function test_RecordUsage() public {
        registry.recordUsage(0);
        registry.recordUsage(0);

        VaultTemplateTypes.VaultTemplate memory template = registry.getTemplate(0);
        assertEq(template.usageCount, 2);
    }

    function test_GetTemplatesByCategory() public view {
        uint256[] memory emergencyTemplates = registry.getTemplatesByCategory(
            VaultTemplateTypes.TemplateCategory.Emergency
        );
        assertEq(emergencyTemplates.length, 1);
    }

    function test_RevertOnEmptyName() public {
        vm.prank(user1);
        vm.expectRevert(VaultTemplateRegistry.InvalidTemplateName.selector);
        registry.createTemplate(
            "",
            "Description",
            VaultTemplateTypes.TemplateCategory.Custom,
            0,
            0,
            address(0)
        );
    }
}
