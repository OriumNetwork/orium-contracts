// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import  { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC4907ShareProfit } from './interfaces/IERC4907ShareProfit.sol';
import { IRewardRecipient } from './interfaces/IRewardRecipient.sol';
import  { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import  { ERC165Checker } from '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';

contract RewardDistributor is Pausable, AccessControl {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  IERC20 public rewardToken;
  IERC4907ShareProfit public nft;

  constructor(address operator_, address rewardToken_, address nft_)   {
    require(operator_ != address(0), "RewardDistributor: operator is the zero address");
    require(rewardToken_ != address(0), "RewardDistributor: rewardToken is the zero address");
    require(nft_ != address(0), "RewardDistributor: nft is the zero address");

    rewardToken = IERC20(rewardToken_);
    nft = IERC4907ShareProfit(nft_);

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(PAUSER_ROLE,operator_);
    _setupRole(OPERATOR_ROLE, operator_);
  }

  function rewardUsers(uint256[] calldata tokenIds, uint256[] calldata  amounts) external onlyRole(OPERATOR_ROLE) {
    require(tokenIds.length == amounts.length, "RewardDistributor: tokenIds and amounts length mismatch");
      for (uint256 i; i < tokenIds.length; i++) {
        uint256 tokenId = tokenIds[i];
        uint256 amount = amounts[i];
        uint256[] memory splits = nft.splitOf(tokenId);
        address[] memory parties = nft.partiesOf(tokenId);
        platformClaim(tokenId, amount,  parties, splits);
      }
    }

    // Token Distribution
    function platformClaim(uint256 tokenId, uint256 amount, address[] memory parties, uint256[] memory splits) internal {
        require(parties.length == splits.length, "RewardDistributor: parties and splits length mismatch");
        for (uint256 i; i < parties.length; i++) {
            address to = parties[i];
            uint256 split = splits[i];
            uint256 amountToTransfer = calculateClaim(amount, split);
            rewardToken.transfer(to, amountToTransfer);
            if (ERC165Checker.supportsInterface(to, type(IRewardRecipient).interfaceId)) {
              
              address[] memory nft_addresses = new address[](1);
              uint256[] memory tokenIds = new uint256[](1);
              uint256[] memory token_amount = new uint256[](1);

              nft_addresses[0] = address(nft);
              tokenIds[0] = tokenId;
              token_amount[0] = amountToTransfer;

              IRewardRecipient(to).onTokenGeneratingEvent(msg.sig, nft_addresses, tokenIds, parties, token_amount);
            }
        }
    }

    function rewardClaim(uint256 tokenId) external {
      if(nft.userOf(tokenId) != address(0)){
        require(msg.sender == nft.userOf(tokenId), "RewardDistributor: caller is not the user");
      }else{
        require(msg.sender == nft.ownerOf(tokenId), "RewardDistributor: caller is not the owner");
      }
      address[] memory parties = nft.partiesOf(tokenId);
      uint256[] memory splits = nft.splitOf(tokenId);
      require(parties.length == splits.length, "RewardDistributor: parties and splits length mismatch");

      for(uint256 i; i < parties.length; i++){
            address to = parties[i];
            uint256 split = splits[i];
            uint256 amountToTransfer = calculateClaim(100 ether, split); //get value from a balance mapping
            rewardToken.transfer(to, amountToTransfer);

        if (ERC165Checker.supportsInterface(to, type(IRewardRecipient).interfaceId)) {
              
              address[] memory nft_addresses = new address[](1);
              uint256[] memory tokenIds = new uint256[](1);
              uint256[] memory token_amount = new uint256[](1);

              nft_addresses[0] = address(nft);
              tokenIds[0] = tokenId;
              token_amount[0] = amountToTransfer;

              IRewardRecipient(to).onTokenGeneratingEvent(msg.sig, nft_addresses, tokenIds, parties, token_amount);
            }
      }
    }
    function calculateClaim(uint256 amount, uint256 split) internal pure returns (uint256) {
        return amount * split / 100;
    }
}
