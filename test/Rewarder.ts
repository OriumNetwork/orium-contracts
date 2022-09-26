import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
const toWei = ethers.utils.parseEther;
const ONE_DAY = 86400;
describe("RewardDistributor", function () {
  let deployer: SignerWithAddress;
  let owner: SignerWithAddress;
  let player1: SignerWithAddress;
  let nftUser: SignerWithAddress;
  let nonContractParty: SignerWithAddress;

  let RewardDistributor: ContractFactory;
  let rewardDistributor: Contract;

  let RewardToken: ContractFactory;
  let rewardToken: Contract;

  let RewardReceiver: ContractFactory;
  let rewardReceiver: Contract;

  let Nft: ContractFactory;
  let nft: Contract;

  before(async function () {
    [deployer, owner, player1, nonContractParty, nftUser] = await ethers.getSigners();
  });

  beforeEach(async function () {

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy(owner.address);
    await rewardToken.deployed();

    Nft = await ethers.getContractFactory("ERC4907ShareProfit");
    nft = await Nft.deploy("Test NFT", "TNFT");
    await nft.deployed();

    RewardDistributor = await ethers.getContractFactory("RewardDistributor");
    rewardDistributor = await RewardDistributor.deploy(owner.address, rewardToken.address, nft.address);
    await rewardDistributor.deployed();

    RewardReceiver = await ethers.getContractFactory("RewardRecipient");
    rewardReceiver = await RewardReceiver.deploy();
    await rewardReceiver.deployed();

    await rewardToken.connect(owner).transfer(rewardDistributor.address, toWei("1000"));

  });

  describe("Deployment", function () {
    it("Should lend a nft and split value between contract and non contract", async function () {
      const tokenId = 1;
      const parties = [rewardReceiver.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUserShareProfit(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
    it("Should lend a nft and split value between contracts", async function () {
      const tokenId = 1;
      const parties = [rewardReceiver.address, rewardReceiver.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUserShareProfit(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
    it("Should lend a nft and split value between non-Contracts", async function () {
      const tokenId = 1;
      const parties = [nonContractParty.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUserShareProfit(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardDistributor.connect(owner).rewardUsers([tokenId], [toWei("100")])).to.not.be.reverted;
    });
  });
});
