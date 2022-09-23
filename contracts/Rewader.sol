// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import './interfaces/IERC4907.sol';
import './interfaces/IOrium.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/introspection/ERC165Checker.sol';

contract Rewarder is Pausable, AccessControl {
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

  IERC20 public rewardToken;
  IERC4907 public nft;


  constructor(address operator_, address rewardToken_, address nft_)   {
    require(operator_ != address(0), "Rewarder: operator is the zero address");
    require(rewardToken_ != address(0), "Rewarder: rewardToken is the zero address");
    require(nft_ != address(0), "Rewarder: nft is the zero address");

    rewardToken = IERC20(rewardToken_);
    nft = IERC4907(nft_);

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(PAUSER_ROLE,operator_);
    _setupRole(OPERATOR_ROLE, operator_);
  }

  function rewardUsers(uint256[] calldata tokenIds, uint256[] calldata  amounts) external onlyRole(OPERATOR_ROLE) {
    require(tokenIds.length == amounts.length, "Rewarder: tokenIds and amounts length mismatch");
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
        require(parties.length == splits.length, "Rewarder: parties and splits length mismatch");
       
        for (uint256 i; i < parties.length; i++) {
            address to = parties[i];
            uint256 split = splits[i];
            uint256 tokensToTransfer = calculateClaim(amount, split);
            rewardToken.transfer(to, tokensToTransfer);
            require(ERC165Checker.supportsInterface(to, type(IOrium).interfaceId), "Rewarder: party does not support IOrium");
            if (ERC165Checker.supportsInterface(to, type(IOrium).interfaceId)) {
              IOrium(to).onTokenClaimed(tokenId, address(nft) ,tokensToTransfer);
            }
        }
    }

    function calculateClaim(uint256 amount, uint256 split) internal pure returns (uint256) {
        return amount * split / 100;
    }
}
