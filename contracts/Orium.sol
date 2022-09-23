// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import '@openzeppelin/contracts/utils/introspection/ERC165Storage.sol';
import './interfaces/IOrium.sol';

contract Orium is ERC165Storage, IOrium {

 uint256 public counter;
  constructor(){
    _registerInterface(type(IOrium).interfaceId);
  }

  function onTokenClaimed(uint256 tokenId, address token_address, uint256 token_amount) external {
    counter++;
  }
}
