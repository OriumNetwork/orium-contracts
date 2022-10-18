// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907Upgradeable } from "./ERC4907Upgradeable.sol";
import { IERC4907ProfitShareUpgradeable } from "../interfaces/IERC4907ProfitShareUpgradeable.sol";
import { IERC4907Upgradeable } from "../interfaces/IERC4907Upgradeable.sol";
import { IERC165Upgradeable } from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

contract ERC4907ProfitShareUpgradeable is ERC4907Upgradeable, IERC4907ProfitShareUpgradeable {
    struct ProfitShareInfo {
        address[] beneficiaries;
        uint256[] split;
    }

    mapping(uint256 => ProfitShareInfo) internal _profits;

    event UpdateProfitShare(uint256 indexed tokenId, address[] beneficiaries, uint256[] split);

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual override(ERC4907Upgradeable, IERC4907Upgradeable) {
        address[] memory beneficiaries_ = new address[](1);
        uint256[] memory split_ = new uint256[](1);
        beneficiaries_[0] = user;
        split_[0] = 100 ether;
        setUserProfitShare(tokenId, user, expires, beneficiaries_, split_);
    }

    function setUserProfitShare(
        uint256 tokenId,
        address user,
        uint64 expires,
        address[] memory beneficiaries,
        uint256[] memory split
    ) public virtual {
        require(beneficiaries.length == split.length, "ERC4907ProfitShare: beneficiaries and split must be the same length");
        require(_isValidSplit(split), "ERC4907ProfitShare: split must be valid");
        super.setUser(tokenId, user, expires);
        _profits[tokenId].beneficiaries = beneficiaries;
        _profits[tokenId].split = split;
        emit UpdateProfitShare(tokenId, beneficiaries, split);
    }

    function _isValidSplit(uint256[] memory split) internal pure returns (bool) {
        uint256 sum = 0;
        for (uint256 i = 0; i < split.length; i++) {
            sum += split[i];
        }
        return sum == 100 ether;
    }

    function beneficiariesOf(uint256 tokenId) public view virtual returns (address[] memory) {
        uint256 lastExpires = _users[tokenId].expires;
        if (lastExpires < block.timestamp) {
            return new address[](0);
        } else {
            return _profits[tokenId].beneficiaries;
        }
    }

    function splitOf(uint256 tokenId) public view virtual returns (uint256[] memory) {
        uint256 lastExpires = _users[tokenId].expires;
        if (lastExpires < block.timestamp) {
            return new uint256[](0);
        } else {
            return _profits[tokenId].split;
        }
    }

    function splitTokensFor(uint256 tokenId, uint256 amount) external view returns (uint256[] memory) {
        uint256[] memory split = splitOf(tokenId);
        uint256[] memory result = new uint256[](split.length);
        for (uint256 i = 0; i < split.length; i++) {
            result[i] = (amount * split[i]) / 100 ether;
        }
        return result;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC4907Upgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId == type(IERC4907ProfitShareUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        if (from != to && _users[tokenId].user != address(0)) {
            address[] memory addresses;
            uint256[] memory splits;
            emit UpdateProfitShare(tokenId, addresses, splits);
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}
