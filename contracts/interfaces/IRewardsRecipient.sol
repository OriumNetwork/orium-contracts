pragma solidity 0.8.9;
import { IERC165 } from '@openzeppelin/contracts/utils/introspection/IERC165.sol' ;
interface IRewardsRecipient is IERC165 {
  function onTokenGeneratingEvent(uint256 tokenId, address token_address, uint256 token_amount) external;
}
