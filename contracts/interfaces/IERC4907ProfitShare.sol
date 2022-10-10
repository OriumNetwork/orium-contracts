// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { IERC4907 } from "../test/IERC4907.sol";
interface IERC4907ProfitShare is IERC4907 {

    // Logged when the user of an NFT is changed or expires is changed
    /// @notice Emitted when the `user` of an NFT or the `expires` of the `user` is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires, address[] beneficiaries, uint256[] split);

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    function setUser(uint256 tokenId, address user, uint64 expires, address[] calldata beneficiaries, uint256[] calldata split) external;

    /// @notice Get the user address of an NFT
    /// @dev The zero address indicates that there is no user or the user is expired
    /// @param tokenId The NFT to get the user address for
    /// @return The user address for this NFT
    function userOf(uint256 tokenId) external view returns(address);

    /// @notice Get the user expires of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the user expires for
    /// @return The user expires for this NFT
    function userExpires(uint256 tokenId) external view returns(uint256);

    // @notice Get the splits of an NFTrenting
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the beneficiaries for
    function splitOf(uint256 tokenId) external view returns(uint256[] memory);

    /// @notice Get the beneficiaries of an NFTreting
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the beneficiaries for
    function beneficiariesOf(uint256 tokenId) external view returns(address[] memory);
}