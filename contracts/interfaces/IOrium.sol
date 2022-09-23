pragma solidity 0.8.9;

interface IOrium is IERC165 {
  function onTokenClaimed(uint256 tokenId, address token_address, uint256 token_amount) external;
}
