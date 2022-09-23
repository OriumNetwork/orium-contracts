import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
const toWei = ethers.utils.parseEther;
const ONE_DAY = 86400;
describe("Rewarder", function () {
  let deployer: SignerWithAddress;
  let owner: SignerWithAddress;
  let player1: SignerWithAddress;
  let nftUser: SignerWithAddress;
  let nonContractParty: SignerWithAddress;

  let Rewarder: ContractFactory;
  let rewarder: Contract;

  let RewardToken: ContractFactory;
  let rewardToken: Contract;

  let Orium: ContractFactory;
  let orium: Contract;

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

    Rewarder = await ethers.getContractFactory("Rewarder");
    rewarder = await Rewarder.deploy(owner.address, rewardToken.address, nft.address);
    await rewarder.deployed();

    Orium = await ethers.getContractFactory("Orium");
    orium = await Orium.deploy();
    await orium.deployed();

    await rewardToken.connect(owner).transfer(rewarder.address, toWei("1000"));

  });

  describe("Deployment", function () {
    it("Should lend a nft and split value between contract and non contract", async function () {
      const tokenId = 1;
      const parties = [orium.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await rewarder.connect(owner).rewardUsers([tokenId], [toWei("100")]);
      expect((await orium.counter()).toString()).to.equal("1");
    });
    it("Should lend a nft and split value between contracts", async function () {
      const tokenId = 1;
      const parties = [orium.address, orium.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await rewarder.connect(owner).rewardUsers([tokenId], [toWei("100")]);
      expect((await orium.counter()).toString()).to.equal("2");
    });
    it("Should lend a nft and split value between non-Contracts", async function () {
      const tokenId = 1;
      const parties = [nonContractParty.address, nonContractParty.address];
      const split = [60, 40];
      await nft.connect(owner).mint(player1.address, tokenId);
      await nft.connect(player1).setUser(tokenId, nftUser.address, ONE_DAY, parties, split);
      await rewarder.connect(owner).rewardUsers([tokenId], [toWei("100")]);
    });
  });
});
