// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/nft/SVGRenderer.sol";

contract SVGRendererTest is Test {
    function test_GenerateSVG() public pure {
        string memory svg = SVGRenderer.generateSVG(
            1,
            5e18,
            10e18,
            block.timestamp + 30 days,
            "ETH",
            false
        );

        assertTrue(bytes(svg).length > 0);
        assertTrue(_contains(svg, "BlueSavings"));
        assertTrue(_contains(svg, "Vault Receipt"));
    }

    function test_GenerateTierBadge() public pure {
        string memory bronzeSvg = SVGRenderer.generateTierBadge(0);
        string memory silverSvg = SVGRenderer.generateTierBadge(1);
        string memory goldSvg = SVGRenderer.generateTierBadge(2);
        string memory platinumSvg = SVGRenderer.generateTierBadge(3);

        assertTrue(_contains(bronzeSvg, "BRONZE"));
        assertTrue(_contains(silverSvg, "SILVER"));
        assertTrue(_contains(goldSvg, "GOLD"));
        assertTrue(_contains(platinumSvg, "PLATINUM"));
    }

    function _contains(string memory str, string memory substr) internal pure returns (bool) {
        bytes memory strBytes = bytes(str);
        bytes memory substrBytes = bytes(substr);

        if (substrBytes.length > strBytes.length) return false;

        for (uint i = 0; i <= strBytes.length - substrBytes.length; i++) {
            bool found = true;
            for (uint j = 0; j < substrBytes.length; j++) {
                if (strBytes[i + j] != substrBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }
}
