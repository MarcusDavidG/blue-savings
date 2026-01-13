// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title SVGRenderer
 * @notice Generates SVG images for vault receipt NFTs
 * @dev On-chain SVG generation for fully decentralized metadata
 */
library SVGRenderer {
    /// @notice Generate SVG for vault receipt
    function generateSVG(
        uint256 vaultId,
        uint256 balance,
        uint256 goalAmount,
        uint256 unlockTimestamp,
        string memory tokenSymbol,
        bool isUnlocked
    ) internal pure returns (string memory) {
        string memory progressBar = _generateProgressBar(balance, goalAmount);
        string memory status = isUnlocked ? "Unlocked" : "Locked";

        return string(abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 500">',
            '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
            '<stop offset="0%" style="stop-color:#0052FF"/>',
            '<stop offset="100%" style="stop-color:#3B82F6"/>',
            '</linearGradient></defs>',
            '<rect width="400" height="500" fill="url(#bg)" rx="20"/>',
            '<text x="200" y="60" text-anchor="middle" fill="white" font-size="24" font-weight="bold">BlueSavings</text>',
            '<text x="200" y="90" text-anchor="middle" fill="white" font-size="14" opacity="0.8">Vault Receipt #',
            _toString(vaultId),
            '</text>',
            '<rect x="30" y="120" width="340" height="200" fill="white" fill-opacity="0.1" rx="10"/>',
            '<text x="50" y="160" fill="white" font-size="14">Token: ',
            tokenSymbol,
            '</text>',
            '<text x="50" y="190" fill="white" font-size="14">Balance: ',
            _formatAmount(balance),
            '</text>',
            '<text x="50" y="220" fill="white" font-size="14">Goal: ',
            goalAmount > 0 ? _formatAmount(goalAmount) : "No Goal",
            '</text>',
            '<text x="50" y="250" fill="white" font-size="14">Status: ',
            status,
            '</text>',
            progressBar,
            '<text x="200" y="470" text-anchor="middle" fill="white" font-size="12" opacity="0.6">base.org</text>',
            '</svg>'
        ));
    }

    function _generateProgressBar(uint256 balance, uint256 goalAmount) internal pure returns (string memory) {
        if (goalAmount == 0) return "";

        uint256 progress = balance >= goalAmount ? 100 : (balance * 100) / goalAmount;
        uint256 barWidth = (280 * progress) / 100;

        return string(abi.encodePacked(
            '<rect x="50" y="280" width="280" height="20" fill="white" fill-opacity="0.2" rx="5"/>',
            '<rect x="50" y="280" width="',
            _toString(barWidth),
            '" height="20" fill="#10B981" rx="5"/>',
            '<text x="200" y="295" text-anchor="middle" fill="white" font-size="12">',
            _toString(progress),
            '%</text>'
        ));
    }

    function _formatAmount(uint256 amount) internal pure returns (string memory) {
        // Simplified formatting - divide by 1e18 for display
        uint256 whole = amount / 1e18;
        return _toString(whole);
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
