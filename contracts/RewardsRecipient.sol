// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC165Storage } from '@openzeppelin/contracts/utils/introspection/ERC165Storage.sol';
import { IRewardsRecipient } from './interfaces/IRewardsRecipient.sol';

contract RewardsRecipient is ERC165Storage {
  constructor(){
    _registerInterface(type(IRewardsRecipient).interfaceId);
  }
 function onTokenGeneratingEvent(uint256 tokenId, address token_address, uint256 token_amount) external{
  //do something
  return;
 }
    
}
