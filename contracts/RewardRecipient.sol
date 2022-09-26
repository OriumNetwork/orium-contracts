// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC165Storage } from '@openzeppelin/contracts/utils/introspection/ERC165Storage.sol';
import { IRewardRecipient } from './interfaces/IRewardRecipient.sol';

contract RewardRecipient is ERC165Storage, IRewardRecipient {
  constructor(){
    _registerInterface(type(IRewardRecipient).interfaceId);
  }
  function onTokenGeneratingEvent(bytes4 event_type, address[] calldata nft_addresses, uint256[] calldata tokenIds, address[] calldata payment_address, uint256[] calldata token_amount) external virtual override returns (bytes4) {
    //do something
    return event_type;
  }
    
}
