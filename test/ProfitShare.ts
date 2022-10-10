import { ethers } from "hardhat";
import { Contract, ContractFactory } from "ethers";
import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";

const toWei = ethers.utils.parseEther;
const ONE_DAY = 86400;

describe("ERC4907ProfitShare", function () {
  let deployer: SignerWithAddress;
  let operator: SignerWithAddress;
  let nftOwner: SignerWithAddress;
  let nftUser: SignerWithAddress;
  let thirdParty: SignerWithAddress;

  let RewardDistributor: ContractFactory;
  let rewardDistributor: Contract;

  let RewardToken: ContractFactory;
  let rewardToken: Contract;

  let Nft: ContractFactory;
  let nft: Contract;

  before(async function () {
    [deployer, operator, nftOwner, nftUser, thirdParty] = await ethers.getSigners();
  });

  beforeEach(async function () {

    RewardToken = await ethers.getContractFactory("RewardToken");
    rewardToken = await RewardToken.deploy(operator.address);
    await rewardToken.deployed();

    Nft = await ethers.getContractFactory("ERC4907ProfitShare");
    nft = await Nft.deploy("Test NFT", "TNFT");
    await nft.deployed();

    RewardDistributor = await ethers.getContractFactory("RewardDistributor");
    rewardDistributor = await RewardDistributor.deploy(operator.address, rewardToken.address, nft.address);
    await rewardDistributor.deployed();

    await rewardToken.connect(operator).transfer(rewardDistributor.address, toWei("1000"));

  });

  describe("setUserProfitShare", function () {
    const tokenId = 1;
    let parties: string[];
    const split = [toWei("60"), toWei("35"), toWei("5")];
    let expires: number;

    beforeEach(async function () {
      parties = [nftOwner.address, nftUser.address, thirdParty.address];
      const TIME_STAMP = (await ethers.provider.getBlock("latest")).timestamp;
      expires = TIME_STAMP + ONE_DAY;
      await nft.connect(operator).mint(nftOwner.address, tokenId);
    })

    it("Should set user and profit share by a nft owner", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, parties, split)).to.emit(nft, "UpdateProfitShare").withArgs(tokenId, parties, split);
    })

    it("Should set user and profit share by a nft operator", async function () {
      await nft.connect(nftOwner).approve(operator.address, tokenId);
      await nft.connect(operator).setUserProfitShare(tokenId, nftUser.address, expires, parties, split);
    })

    it("Should NOT set user profit share by a nft user", async function () {
      await expect(nft.connect(nftUser).setUserProfitShare(tokenId, nftUser.address, expires, parties, split)).to.be.reverted;
    })

    it("Should NOT set user profit share in case of split and parties length mismatch", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, parties, [60, 40])).to.be.revertedWith("ERC4907ProfitShare: parties and split must be the same length");
    })

    it("Should NOT set user profit share if the sum of split it's not equal to 100 ether", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, parties, [toWei("60"), toWei("35"), toWei("4")])).to.be.revertedWith("ERC4907ProfitShare: split must be valid");
    })

  });

  describe("RewardDistributor", function () {
    const tokenId = 1;
    let parties: string[];
    const split = [toWei("60"), toWei("35"), toWei("5")];
    const rewardAmount = toWei("100");

    beforeEach(async function () {
      parties = [nftOwner.address, nftUser.address, thirdParty.address];
      await nft.connect(operator).mint(nftOwner.address, tokenId);
    })

    it("Should lend a nft and split value between parties in airdroping distribution", async function () {
      await nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, ONE_DAY, parties, split);
      await expect(rewardDistributor.connect(operator).rewardUsers([tokenId], [rewardAmount])).to.not.be.reverted;
    });

  });

});
