// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC4907 } from "./test/ERC4907.sol";
import { IERC4907ProfitShare } from "./interfaces/IERC4907ProfitShare.sol";

  contract ERC4907ProfitShare is ERC4907{
    
    struct ProfitShareInfo 
    {
        address[] parties; // address of parties
        uint256[] split;   // split of parties
    }

    mapping (uint256  => ProfitShareInfo) internal _profits;

    /// @notice Emited when the profit of an NFT is updated
    /// @dev parties and split neeed to be the same length
    /// @param tokenId The NFT to update the profit for
    /// @param parties The parties to split the profit
    /// @param split The split of the profit
    event UpdateProfitShare(uint256 indexed tokenId, address[] parties, uint256[] split);

    constructor(string memory name_, string memory symbol_) ERC4907(name_, symbol_) {}
    
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires) public virtual override{
        address[] memory parties_ = new address[](1);
        uint256[] memory split_ = new uint256[](1);
        parties_[0] = user;
        split_[0] = 1;
        setUserProfitShare(tokenId, user, expires,  parties_ , split_);
    }

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param tokenId  The NFT to update the profit for
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    /// @param parties The parties to split the profit
    /// @param split The split of the profit
    function setUserProfitShare(uint256 tokenId, address user, uint64 expires, address[] memory parties, uint256[] memory split) public virtual {
        require(parties.length == split.length, "ERC4907ProfitShare: parties and split must be the same length");
        require(_isValidSplit(split), "ERC4907ProfitShare: split must be valid");
        super.setUser(tokenId, user, expires);
        _profits[tokenId].parties = parties;
        _profits[tokenId].split = split;
        emit UpdateProfitShare(tokenId, parties, split);
    }
    function _isValidSplit(uint256[] memory split) internal pure returns (bool){
        uint256 sum = 0;
        for(uint256 i = 0; i < split.length; i++){
            sum += split[i];
        }
        return sum == 100 ether;
    }
    function partiesOf(uint256 tokenId) public view virtual returns(address[] memory){
        return _profits[tokenId].parties;
    }

    function splitOf(uint256 tokenId) public view virtual returns(uint256[] memory){
        return _profits[tokenId].split;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907ProfitShare).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId);
     
        if (from != to && _users[tokenId].user != address(0)) {
            address[] memory addresses;
            uint256[] memory splits;
            delete _users[tokenId];
            delete _profits[tokenId];
            emit UpdateUser(tokenId, address(0),0);
            emit UpdateProfitShare(tokenId, addresses, splits);
        }
    }
      function mint(address to, uint256 tokenId) public virtual {
        super._mint(to, tokenId);
    }
} 