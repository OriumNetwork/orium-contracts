// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907 } from "./ERC4907.sol";
import { IERC4907ProfitShare } from "./interfaces/IERC4907ProfitShare.sol";

contract ERC4907ProfitShare is ERC4907 {
    struct ProfitShareInfo {
        address[] beneficiaries;
        uint256[] shares;
    }

    mapping(uint256 => ProfitShareInfo) internal _profitShareConfigs;

    event UpdateProfitShare(uint256 indexed tokenId, address[] beneficiaries, uint256[] shares);

    constructor(string memory name_, string memory symbol_) ERC4907(name_, symbol_) {}

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
        ProfitShareInfo memory info = profitShareOf(tokenId);
        _beneficiaries = info.beneficiaries;
        _amounts = new uint256[](_beneficiaries.length);
        for (uint256 i = 0; i < info.shares.length; i++) {
            _amounts[i] = (amount * info.shares[i]) / 100 ether;
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
        if (from != to) {
            address[] memory beneficiaries = new address[](1);
            uint256[] memory shares = new uint256[](1);
            beneficiaries[0] = to;
            shares[0] = 100 ether;
            _profitShareConfigs[tokenId] = ProfitShareInfo({ beneficiaries: beneficiaries, shares: shares });
            emit UpdateProfitShare(tokenId, beneficiaries, shares);
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}
