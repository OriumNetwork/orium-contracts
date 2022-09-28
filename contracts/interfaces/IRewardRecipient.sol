pragma solidity 0.8.9;
import { IERC165 } from '@openzeppelin/contracts/utils/introspection/IERC165.sol' ;
interface IRewardRecipient is IERC165 {
function onTokenGeneratingEvent(bytes4 event_type, address[] calldata nft_addresses, uint256[] calldata tokenIds, address[] calldata payment_address, uint256[] calldata token_amount) external virtual;
}
