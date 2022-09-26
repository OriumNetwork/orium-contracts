// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import  { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC4907 } from './interfaces/IERC4907.sol';
import { IRewardsRecipient } from './interfaces/IRewardsRecipient.sol';
import  { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import  { ERC165Checker } from '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';

contract RewardsDistributor is Pausable, AccessControl {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  IERC20 public rewardToken;
  IERC4907 public nft;

  constructor(address operator_, address rewardToken_, address nft_)   {
    require(operator_ != address(0), "RewardsDistributor: operator is the zero address");
    require(rewardToken_ != address(0), "RewardsDistributor: rewardToken is the zero address");
    require(nft_ != address(0), "RewardsDistributor: nft is the zero address");

    rewardToken = IERC20(rewardToken_);
    nft = IERC4907(nft_);

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(PAUSER_ROLE,operator_);
    _setupRole(OPERATOR_ROLE, operator_);
  }

  function rewardUsers(uint256[] calldata tokenIds, uint256[] calldata  amounts) external onlyRole(OPERATOR_ROLE) {
    require(tokenIds.length == amounts.length, "RewardsDistributor: tokenIds and amounts length mismatch");
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
        require(parties.length == splits.length, "RewardsDistributor: parties and splits length mismatch");
       
        for (uint256 i; i < parties.length; i++) {
            address to = parties[i];
            uint256 split = splits[i];
            uint256 tokensToTransfer = calculateClaim(amount, split);
            rewardToken.transfer(to, tokensToTransfer);
            if (ERC165Checker.supportsInterface(to, type(IRewardsRecipient).interfaceId)) {
              IRewardsRecipient(to).onTokenGeneratingEvent(tokenId, address(nft) ,tokensToTransfer);
            }
        }
    }

    function calculateClaim(uint256 amount, uint256 split) internal pure returns (uint256) {
        return amount * split / 100;
    }
}
