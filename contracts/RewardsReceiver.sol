// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC165Storage } from '@openzeppelin/contracts/utils/introspection/ERC165Storage.sol';
import { IRewardsReceiver } from './interfaces/IRewardsReceiver.sol';

contract RewardsReceiver is ERC165Storage {
  constructor(){
    _registerInterface(type(IRewardsReceiver).interfaceId);
  }
 function onTokenGeneratingEvent(uint256 tokenId, address token_address, uint256 token_amount) external{
  //do something
  return;
 }
    
}
