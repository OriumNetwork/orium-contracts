# Orium Contracts

![Github Badge](https://github.com/OriumNetwork/orium-aavegotchi-lending/actions/workflows/master.yaml/badge.svg)
[![Coverage Status](https://coveralls.io/repos/github/OriumNetwork/orium-contracts/badge.svg?branch=master)](https://coveralls.io/github/OriumNetwork/orium-contracts?branch=master)
[![solidity - v0.8.9](https://img.shields.io/static/v1?label=solidity&message=v0.8.9&color=2ea44f&logo=solidity)](https://github.com/OriumNetwork)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Discord](https://img.shields.io/discord/1009147970832322632?label=discord&logo=discord&logoColor=white)](https://discord.gg/NaNTgPK5rx)
[![Twitter Follow](https://img.shields.io/twitter/follow/oriumnetwork?label=Follow&style=social)](https://twitter.com/OriumNetwork)

Orium Contracts is a Hardhat Solidity project that implements ERC4907ProfitShare a 
extension to [ERC4907](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4907.md) lending protocol standard.

## Run Locally
```shell
npx hardhat test
```

## New Functions Added

The following table describes the main changes and functions in ERC4907ProfitShare smart contract.

|  **Function**  	|    **Arguments**    	|                           **Observations**                                                    	                            | **Description**                                                                                                                	|
|:-----------:	|:----------------:	|:-----------------------------------------------------------------------------------------------------------------------:|--------------------------------------------------------------------------------------------------------------------------------	|
|    `setUserProfitShare`   	|      `uint256 tokenId, address user, uint64 expires, address[] memory parties, uint256[] memory split`      	|                `parties and split needs to have the same array length. The sum of splits must be equal to 100 ether (100%) `                             	                | Similar function to the original setUser, but now stores aditional information usefull to claim or air drop reward farmed by nft.                                                      	|
|  `setUser` 	|   `uint256 tokenId, address user, uint64 expires`   	| `` 	 | overrides original function to call setUserProfitShare and set the user as only party and split to 100 ethers (100%)                                               	|
|   `partiesOf`  	|   `uint256 tokenId`   	|                ``                              	                | returns parties setted in the nft                             	|
| `splitOf` 	| `uint256 tokenId` 	| `` 	 | returns split setted in the nft                        	|
|  `_beforeTokenTransfer`  	|     ` address from, address to, uint256 tokenId`     	|                        `must be a valid id`                                            	                        | overrides original function to reset split and parties when ownership is changed 	|
