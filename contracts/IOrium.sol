// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/introspection/ERC165.sol';

contract IOrium is ERC165 {

 uint256 public counter;
  constructor(){

  }

  function onTokenClaimed(uint256 tokenId, address token_address, uint256 token_amount) external {
    counter++;
  }
}
