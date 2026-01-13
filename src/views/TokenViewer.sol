// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IERC20Metadata.sol";

/**
 * @title TokenViewer
 * @notice View token information for frontend
 */
contract TokenViewer {
    struct TokenInfo {
        address token;
        string name;
        string symbol;
        uint8 decimals;
        uint256 balance;
    }

    function getTokenInfo(address token, address account) external view returns (TokenInfo memory) {
        IERC20Metadata t = IERC20Metadata(token);
        return TokenInfo({
            token: token,
            name: t.name(),
            symbol: t.symbol(),
            decimals: t.decimals(),
            balance: t.balanceOf(account)
        });
    }

    function getTokenInfoBatch(address[] calldata tokens, address account) 
        external 
        view 
        returns (TokenInfo[] memory infos) 
    {
        infos = new TokenInfo[](tokens.length);
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20Metadata t = IERC20Metadata(tokens[i]);
            infos[i] = TokenInfo({
                token: tokens[i],
                name: t.name(),
                symbol: t.symbol(),
                decimals: t.decimals(),
                balance: t.balanceOf(account)
            });
        }
    }
}
