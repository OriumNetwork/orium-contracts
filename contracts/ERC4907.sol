// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { IERC4907 } from "./interfaces/IERC4907.sol";

  contract ERC4907 is ERC721{
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
        address[] parties; // array of parties
        uint256[] split; // array of split
    }

    mapping (uint256  => UserInfo) internal _users;

    // Logged when the user of an NFT is changed or expires is changed
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires, address[] parties, uint256[] split);

    constructor(string memory name_, string memory symbol_)
     ERC721(name_, symbol_)
     {
     }
    
    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires, address[] calldata parties, uint256[] calldata split) public virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC4907: transfer caller is not owner nor approved");
        require(parties.length == split.length, "ERC4907: parties and split must be the same length");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        info.parties = parties;
        info.split = split;
        emit UpdateUser(tokenId, user, expires, parties, split);
    }

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) public view virtual returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user;
        }
        else{
            return address(0);
        }
    }

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _users[tokenId].expires;
    }

    function partiesOf(uint256 tokenId) public view virtual returns(address[] memory){
        return _users[tokenId].parties;
    }

    function splitOf(uint256 tokenId) public view virtual returns(uint256[] memory){
        return _users[tokenId].split;
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
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
            emit UpdateUser(tokenId, address(0),0, addresses, splits);
        }
    }

    function mint(address to, uint256 tokenId) public virtual{
        _mint(to, tokenId);
    }
} 