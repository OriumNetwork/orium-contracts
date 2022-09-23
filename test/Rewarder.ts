import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";

describe("Rewarder", function () {
  let deployer: SignerWithAddress;
  let owner: SignerWithAddress;

  let Rewarder: ContractFactory;
  let rewarder: Contract;

  let RewardToken: ContractFactory;
  let rewardToken: Contract;

  let Nft: ContractFactory;
  let nft: Contract;

  before(async function () {
    [deployer, owner] = await ethers.getSigners();
  });

  beforeEach(async function () {

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy();
    await rewardToken.deployed();

    Nft = await ethers.getContractFactory("Nft");
    nft = await Nft.deploy();
    await nft.deployed();

    Rewarder = await ethers.getContractFactory("Rewarder");
    rewarder = await Rewarder.deploy(rewardToken.address, nft.address);
    await rewarder.deployed();

  });

  describe("Deployment", function () {

  });
});
