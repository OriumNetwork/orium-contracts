// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907ProfitShare } from "../ERC4907ProfitShare.sol";

contract ERC4907ProfitShareNft is ERC4907ProfitShare {
    constructor(string memory name_, string memory symbol_) ERC4907ProfitShare(name_, symbol_) {}

    function mint(address to, uint256 tokenId) public virtual {
        super._mint(to, tokenId);
    }
}
