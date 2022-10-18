// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907Upgradeable } from "./ERC4907Upgradeable.sol";
import { IERC4907ProfitShareUpgradeable } from "../interfaces/IERC4907ProfitShareUpgradeable.sol";
import { IERC4907Upgradeable } from "../interfaces/IERC4907Upgradeable.sol";
import { IERC165Upgradeable } from "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";

contract ERC4907ProfitShareUpgradeable is ERC4907Upgradeable, IERC4907ProfitShareUpgradeable {
    struct ProfitShareInfo {
        address[] beneficiaries;
        uint256[] shares;
    }

    mapping(uint256 => ProfitShareInfo) internal _profitShareConfigs;

    event UpdateProfitShare(uint256 indexed tokenId, address[] beneficiaries, uint256[] shares);

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) public virtual override {
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
        uint256[] memory shares
    ) public virtual {
        require(beneficiaries.length == shares.length, "ERC4907ProfitShare: beneficiaries and shares must be the same length");
        require(_isValidShares(shares), "ERC4907ProfitShare: shares must be valid");
        super.setUser(tokenId, user, expires);
        _profitShareConfigs[tokenId].beneficiaries = beneficiaries;
        _profitShareConfigs[tokenId].shares = shares;
        emit UpdateProfitShare(tokenId, beneficiaries, shares);
    }

    function _isValidShares(uint256[] memory shares) internal pure returns (bool) {
        uint256 sum = 0;
        for (uint256 i = 0; i < shares.length; i++) {
            sum += shares[i];
        }
        return sum == 100 ether;
    }

    function profitShareOf(uint256 tokenId) public view returns (ProfitShareInfo memory) {
        uint256 lastExpires = _users[tokenId].expires;

        if (lastExpires > block.timestamp) {
            return _profitShareConfigs[tokenId];
        } else {
            address[] memory beneficiaries = new address[](1);
            uint256[] memory shares = new uint256[](1);
            beneficiaries[0] = ownerOf(tokenId);
            shares[0] = 100 ether;
            return ProfitShareInfo({ beneficiaries: beneficiaries, shares: shares });
        }
    }

    function splitTokensFor(uint256 tokenId, uint256 amount) external view returns (uint256[] memory _amounts, address[] memory _beneficiaries) {
        uint256[] memory shares = profitShareOf(tokenId).shares;
        _beneficiaries = profitShareOf(tokenId).beneficiaries;
        _amounts = new uint256[](_beneficiaries.length);
        for (uint256 i = 0; i < shares.length; i++) {
            _amounts[i] = (amount * shares[i]) / 100 ether;
        }
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907ProfitShare).interfaceId || super.supportsInterface(interfaceId);
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
