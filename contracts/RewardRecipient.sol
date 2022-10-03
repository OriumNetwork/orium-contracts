// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ERC165Storage } from '@openzeppelin/contracts/utils/introspection/ERC165Storage.sol';
import { IRewardRecipient } from './interfaces/IRewardRecipient.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { AccessControl } from '@openzeppelin/contracts/access/AccessControl.sol';
import { Pausable } from '@openzeppelin/contracts/security/Pausable.sol';
import { IERC165 } from '@openzeppelin/contracts/utils/introspection/IERC165.sol';
import { Initializable } from '@openzeppelin/contracts/proxy/utils/Initializable.sol';
contract RewardRecipient is ERC165Storage, IRewardRecipient, AccessControl, Pausable, Initializable {
  bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
  bytes32 public constant NOTIFIER_ROLE = keccak256('NOTIFIER_ROLE');
  bytes32 public constant OPERATOR_ROLE = keccak256('OPERATOR_ROLE');

  event Signatures(bytes4[] sigs);
  mapping(address => mapping(address => mapping(uint256 => uint256))) public rewardTokenToNftToTokenIdToBalance;
  mapping(address => mapping(address => uint256)) public rewardTokenToNftToBalance;
  mapping(address => bool) public trustedNotifiers;

  mapping(address => mapping(bytes4 => bool)) public notifierToSignatureToTrusted;

  function initialize(address _operator) public initializer {

    require(_operator != address(0), 'RewardRecipient: operator is the zero address');
    
    _registerInterface(type(IRewardRecipient).interfaceId);
    _setupRole(DEFAULT_ADMIN_ROLE, _operator);
    _setupRole(PAUSER_ROLE, _operator);
    _setupRole(OPERATOR_ROLE, _operator);
  }
  function onTokenGeneratingEvent(bytes4 event_type, address[] calldata nft_addresses, uint256[] calldata tokenIds, address[] calldata payment_address, uint256[] calldata token_amount) external virtual override onlyRole(NOTIFIER_ROLE) {
    //do something
    require(notifierToSignatureToTrusted[msg.sender][event_type], 'RewardRecipient: Notifier is not trusted for this event type');
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Storage, AccessControl, IERC165) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function setTrustedNotifiers(address[] calldata notifiers, bool[] calldata trusted) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(notifiers.length == trusted.length, "RewardRecipient: notifiers and trusted arrays must be the same length");
    for(uint256 i = 0; i < notifiers.length; i++){
      require(notifiers[i] != address(0), "RewardRecipient: notifier address cannot be 0x0");
      trustedNotifiers[notifiers[i]] = trusted[i];
      _setupRole(NOTIFIER_ROLE, notifiers[i]);
    }
  }

  function pause () external onlyRole(PAUSER_ROLE) {
    _pause();
  }

  function unpause () external onlyRole(PAUSER_ROLE) {
    _unpause();
  }
    
}
