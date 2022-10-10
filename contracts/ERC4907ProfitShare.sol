// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907 } from "./test/ERC4907.sol";
import { IERC4907ProfitShare } from "./interfaces/IERC4907ProfitShare.sol";
  contract ERC4907ProfitShare is ERC4907{
    
    struct ProfitShareInfo 
    {
        address[] beneficiaries; 
        uint256[] split; 
    }

    mapping (uint256 => ProfitShareInfo) internal _profits;

    event UpdateProfitShare(uint256 indexed tokenId, address[] beneficiaries, uint256[] split);

    constructor(string memory name_, string memory symbol_) ERC4907(name_, symbol_) {}
    
     function setUser(uint256 tokenId, address user, uint64 expires) public virtual override{
        address[] memory beneficiaries_ = new address[](1);
        uint256[] memory split_ = new uint256[](1);
        beneficiaries_[0] = user;
        split_[0] = 1;
        setUserProfitShare(tokenId, user, expires,  beneficiaries_ , split_);
    }

    function setUserProfitShare(uint256 tokenId, address user, uint64 expires, address[] memory beneficiaries, uint256[] memory split) public virtual {
        require(beneficiaries.length == split.length, "ERC4907ProfitShare: beneficiaries and split must be the same length");
        require(_isValidSplit(split), "ERC4907ProfitShare: split must be valid");
        super.setUser(tokenId, user, expires);
        _profits[tokenId].beneficiaries = beneficiaries;
        _profits[tokenId].split = split;
        emit UpdateProfitShare(tokenId, beneficiaries, split);
    }
    function _isValidSplit(uint256[] memory split) internal pure returns (bool){
        uint256 sum = 0;
        for(uint256 i = 0; i < split.length; i++){
            sum += split[i];
        }
        return sum == 100 ether;
    }
    function beneficiariesOf(uint256 tokenId) public view virtual returns(address[] memory){
        return _profits[tokenId].beneficiaries;
    }

    function splitOf(uint256 tokenId) public view virtual returns(uint256[] memory){
        return _profits[tokenId].split;
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
      function mint(address to, uint256 tokenId) public virtual {
        super._mint(to, tokenId);
    }
} 