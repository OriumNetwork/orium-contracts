// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.9;

import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";
import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";
import { IERC4907ProfitShare } from '../interfaces/IERC4907ProfitShare.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import { ERC165Checker } from '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';

contract RewardDistributor is Pausable, AccessControl {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  IERC20 public rewardToken;
  IERC4907ProfitShare public nft;

  constructor(address operator_, address rewardToken_, address nft_) {
    require(operator_ != address(0), "RewardDistributor: operator is the zero address");
    require(rewardToken_ != address(0), "RewardDistributor: rewardToken is the zero address");
    require(nft_ != address(0), "RewardDistributor: nft is the zero address");

    rewardToken = IERC20(rewardToken_);
    nft = IERC4907ProfitShare(nft_);

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(PAUSER_ROLE,operator_);
    _setupRole(OPERATOR_ROLE, operator_);
  }

  function rewardUsers(uint256[] calldata tokenIds, uint256[] calldata  amounts) external onlyRole(OPERATOR_ROLE) {
    require(tokenIds.length == amounts.length, "RewardDistributor: tokenIds and amounts length mismatch");
      for (uint256 i; i < tokenIds.length; i++) {
        _rewardUser(tokenIds[i], amounts[i]);
      }
    }

  // Token Distribution
  function _rewardUser(uint256 tokenId, uint256 amount) internal {
         address[] memory parties = nft.beneficiariesOf(tokenId);
         uint256[] memory splits = nft.splitOf(tokenId);
        require(parties.length == splits.length, "RewardDistributor: parties and splits length mismatch");
        for (uint256 i; i < parties.length; i++) {
            address to = parties[i];
            uint256 split = splits[i];
            uint256 amountToTransfer = calculateClaim(amount, split);
            rewardToken.transfer(to, amountToTransfer);
        }
    }

    function rewardClaim(uint256 tokenId) external {
      if(nft.userOf(tokenId) != address(0)){
        require(msg.sender == nft.userOf(tokenId), "RewardDistributor: caller is not the user");
      }else{
        require(msg.sender == nft.ownerOf(tokenId), "RewardDistributor: caller is not the owner");
      }
      uint256 amountToTransfer = 100 ether; //calculate value farmed by nft
      _rewardUser(tokenId, amountToTransfer);
    }
    function calculateClaim(uint256 amount, uint256 split) internal pure returns (uint256) {
        return amount * split / 100 ether;
    }
}
