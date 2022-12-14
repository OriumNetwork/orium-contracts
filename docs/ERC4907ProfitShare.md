# ERC-4907 Profit-Share Extension

## Abstract

Orium's ERC-4907 Profit-Share is an extension of the [ERC-4907](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4907.md)
standard. It proposes to store two additional arrays (`beneficiaries` and `shares`) to enable developers to distribute
rewards across multiple beneficiaries.

## Motivation

In early 2022, a new ethereum improvement proposal was introduced that added a new role to the ERC-721 standard.
ERC-4907 included the `user` role to enable NFT owners to assign another address that can use a specific NFT. As more
and more projects implement this standard, Orium developed a simple extension that expands this scope to support
profit-share-based rentals.

## Specification

The interface below lists all new events and functions included in this extension. Note that every ERC-4907
Profit-Share compliant contract must implement the ERC-4907 interface.

```solidity
pragma solidity ^0.8.9;

import { IERC4907 } from "../contracts/interfaces/IERC4907.sol";

interface IERC4907ProfitShare is IERC4907 {
  struct ProfitShareInfo {
    address[] beneficiaries;
    uint256[] shares;
  }

  /// @notice Emitted when the `profitShare` of an NFT is changed
  event UpdateProfitShare(uint256 indexed tokenId, address[] beneficiaries, uint256[] shares);

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
  /// @param tokenId The NFT to get the profit share
  function profitShareOf(uint256 tokenId) external view returns (ProfitShareInfo memory);
  
  /// @notice Get the amount of tokens to distribute to each beneficiary
  /// @param tokenId The tokenId of the NFT
  /// @param amount The amount of tokens to be splitted
  function splitTokensFor(uint256 tokenId, uint256 amount) external view returns (address[] memory, uint256[] memory);
}
```

### Monitoring User Rights & Profit-Share Assignment

In order to find out which user holds access rights for an NFT, and whom are the beneficiaries, developers can either:

- Call view functions to return the desired information. `userOf(uint256 tokenId)` should return the user address, and
  `profitShareOf(uint256 tokenId)` should return the reward recipients and their respective shares.
- Build a database to monitor the events `UpdateUser` and `UpdateProfitShare`. Each time these events are emitted, the
  database must be updated with the new values and the expiration date.

### Caveats

- One can check if a contract implements `IERC4907ProfitShare` with ERC-165 `supportsInterface`.
- Since no event will be emitted when the user rights expires, it's important to build logic to automatically expire
  users and beneficiaries at the expiration date.
- The event `UpdateProfitShare` contains two arrays: `beneficiaries` and `shares`. Each beneficiary is entitled to a 
  share of the tokens earned, defined by the value of `shares`. 100% of the total tokens is equal to 100 ether, 
  meaning that 10% is 10e18, 5% is 5e18 and so on. The sum of all the items of the `shares` array should always be
  100 ether (or 100%).
- To calculate how many tokens should be transferred to each beneficiary, `splitTokensFor` should be used. It will split the
  amount of tokens between the `beneficiaries` at the rate stored at `shares`.
