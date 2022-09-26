import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
const toWei = ethers.utils.parseEther;
const ONE_DAY = 86400;
describe("RewardsDistributor", function () {
  let deployer: SignerWithAddress;
  let owner: SignerWithAddress;
  let player1: SignerWithAddress;
  let nftUser: SignerWithAddress;
  let nonContractParty: SignerWithAddress;

  let RewardsDistributor: ContractFactory;
  let rewardsDistributor: Contract;

  let RewardToken: ContractFactory;
  let rewardToken: Contract;

  let RewardsReceiver: ContractFactory;
  let rewardsReceiver: Contract;

  let Nft: ContractFactory;
  let nft: Contract;

  before(async function () {
    [deployer, owner, player1, nonContractParty, nftUser] = await ethers.getSigners();
  });

  beforeEach(async function () {

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy(owner.address);
    await rewardToken.deployed();

    Nft = await ethers.getContractFactory("ERC4907");
    nft = await Nft.deploy("Test NFT", "TNFT");
    await nft.deployed();

    RewardsDistributor = await ethers.getContractFactory("RewardsDistributor");
    rewardsDistributor = await RewardsDistributor.deploy(owner.address, rewardToken.address, nft.address);
    await rewardsDistributor.deployed();

    RewardsReceiver = await ethers.getContractFactory("RewardsReceiver");
    rewardsReceiver = await RewardsReceiver.deploy();
    await rewardsReceiver.deployed();

    await rewardToken.connect(owner).transfer(rewardsDistributor.address, toWei("1000"));

  });

  describe("Deployment", function () {
    it("Should lend a nft and split value between contract and non contract", async function () {
      const tokenId = 1;
      const parties = [rewardsReceiver.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardsDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
    it("Should lend a nft and split value between contracts", async function () {
      const tokenId = 1;
      const parties = [rewardsReceiver.address, rewardsReceiver.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardsDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
    it("Should lend a nft and split value between non-Contracts", async function () {
      const tokenId = 1;
      const parties = [nonContractParty.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardsDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
  });
});
