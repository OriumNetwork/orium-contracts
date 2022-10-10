// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { IERC4907 } from "../interfaces/IERC4907.sol";

interface IERC4907ProfitShare is IERC4907 {
    /// Logged when the profit share of an NFT is changed
    /// @notice Emitted when the `profitShare` of an NFT is changed
    /// The zero address for user indicates that there is no user address
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires, address[] beneficiaries, uint256[] split);

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// beneficiaries and split must have the same length
    /// @param tokenId The id of the NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    /// @param beneficiaries  The beneficiaries of the NFT
    /// @param split  The split of the NFT
    function setUserProfitShare(
        uint256 tokenId,
        address user,
        uint64 expires,
        address[] calldata beneficiaries,
        uint256[] calldata split
    ) external;

    /// @notice Get the splits of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the split
    function splitOf(uint256 tokenId) external view returns (uint256[] memory);

    /// @notice Get the beneficiaries of an NFT
    /// @dev The zero value indicates that there is no user
    /// @param tokenId The NFT to get the beneficiaries
    function beneficiariesOf(uint256 tokenId) external view returns (address[] memory);
}
