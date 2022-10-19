// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { IERC4907Upgradeable } from "./IERC4907Upgradeable.sol";

interface IERC4907ProfitShareUpgradeable is IERC4907Upgradeable {
    struct ProfitShareInfo {
        address[] beneficiaries;
        uint256[] shares;
    }

    /// @notice Emitted when the `profitShare` of an NFT is changed
    event UpdateUserProfiShare(uint256 indexed tokenId, address indexed user, uint64 expires, address[] beneficiaries, uint256[] shares);

    /// @notice set the user and expires of an NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// beneficiaries and shares must have the same length
    /// @param tokenId The id of the NFT
    /// @param user  The new user of the NFT
    /// @param expires  UNIX timestamp, The new user could use the NFT before expires
    /// @param beneficiaries  The beneficiaries of the NFT
    /// @param shares  The shares of the NFT
    function setUserProfitShare(
        uint256 tokenId,
        address user,
        uint64 expires,
        address[] calldata beneficiaries,
        uint256[] calldata shares
    ) external;

    /// @notice Get the profit share of an NFT
    /// @dev The user address will never be zero
    /// @param tokenId The NFT to get the profit share
    function profitShareOf(uint256 tokenId) external view returns (ProfitShareInfo memory);

    /// @notice Get the amount of tokens to distribute to each beneficiary
    /// @param tokenId The tokenId of the NFT
    /// @param amount The amount of tokens to be splitted
    function splitTokensFor(uint256 tokenId, uint256 amount) external view returns (uint256[] memory, address[] memory);
}
