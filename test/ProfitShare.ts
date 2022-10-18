import { ethers } from "hardhat";
import { BigNumber, Contract, ContractFactory } from "ethers";
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

    Nft = await ethers.getContractFactory("ERC4907ProfitShareNft");
    nft = await Nft.deploy("Test NFT", "TNFT");
    await nft.deployed();

    RewardDistributor = await ethers.getContractFactory("RewardDistributor");
    rewardDistributor = await RewardDistributor.deploy(operator.address, rewardToken.address, nft.address);
    await rewardDistributor.deployed();

    await rewardToken.connect(operator).transfer(rewardDistributor.address, toWei("10000000"));

  });

  describe("setUserProfitShare", function () {
    const tokenId = 1;
    let beneficiaries: string[];
    const shares = [toWei("60"), toWei("35"), toWei("5")];
    let expires: number;

    beforeEach(async function () {
      beneficiaries = [nftOwner.address, nftUser.address, thirdParty.address];
      const TIME_STAMP = (await ethers.provider.getBlock("latest")).timestamp;
      expires = TIME_STAMP + ONE_DAY;
      await nft.connect(operator).mint(nftOwner.address, tokenId);
    })

    it("Should set user and profit share by a nft owner", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, beneficiaries, shares)).to.emit(nft, "UpdateProfitShare").withArgs(tokenId, beneficiaries, shares);
      const profitShareInfo = await nft.profitShareOf(tokenId)
      expect(profitShareInfo.beneficiaries).to.deep.equal(beneficiaries);
      expect(profitShareInfo.shares).to.deep.equal(shares);
    });
    it("Should set user and profit share by a nft operator", async function () {
      await nft.connect(nftOwner).approve(operator.address, tokenId);
      await expect(nft.connect(operator).setUserProfitShare(tokenId, nftUser.address, expires, beneficiaries, shares)).to.emit(nft, "UpdateProfitShare").withArgs(tokenId, beneficiaries, shares);
    })
    it("Should set user using legacy function", async function () {
      await expect(nft.connect(nftOwner).setUser(tokenId, nftUser.address, expires)).to.emit(nft, "UpdateProfitShare").withArgs(tokenId, [nftUser.address], [toWei("100")]);
      const profitShareInfo = await nft.profitShareOf(tokenId)
      expect(profitShareInfo.beneficiaries).to.deep.equal([nftUser.address]);
      expect(profitShareInfo.shares).to.deep.equal([toWei("100")]);
    })
    it("Should NOT set user profit share by a nft user", async function () {
      await expect(nft.connect(nftUser).setUserProfitShare(tokenId, nftUser.address, expires, beneficiaries, shares)).to.be.reverted;
    })
    it("Should NOT set user profit share in case of shares and beneficiaries length mismatch", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, beneficiaries, [60, 40])).to.be.revertedWith("ERC4907ProfitShare: beneficiaries and shares must be the same length");
    })
    it("Should NOT set user profit share if the sum of shares it's not equal to 100 ether", async function () {
      await expect(nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, expires, beneficiaries, [toWei("60"), toWei("35"), toWei("4")])).to.be.revertedWith("ERC4907ProfitShare: shares must be valid");
    })
    it("Should emit UpdateShareProfit and UpdateUser when transferred after a setUser", async function () {
      await nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, ONE_DAY, beneficiaries, shares);
      await expect(nft.connect(nftOwner).transferFrom(nftOwner.address, nftUser.address, tokenId)).to.emit(nft, "UpdateProfitShare").and.to.emit(nft, "UpdateUser");
    })
    it("Should return shares tokens amount", async function () {
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore.timestamp;
      await nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, timestampBefore + ONE_DAY, beneficiaries, shares);
      const amountToSplit = toWei("100");
      const amountsSplitted = await nft.connect(nftUser).splitTokensFor(tokenId, amountToSplit)
      expect(amountsSplitted._amounts).to.be.deep.equal(shares);
      expect(amountsSplitted._beneficiaries).to.be.deep.equal(beneficiaries);
    })
    it("Should check if supports ProfitShare interface", async function () {
      const correctInterfaceId = Nft.interface.getSighash("supportsInterface(bytes4)")
      expect(await nft.supportsInterface(correctInterfaceId)).to.be.true;
    })
  });

  describe("RewardDistributor", function () {
    const tokenId = 1;
    let beneficiaries: string[];
    const shares = [toWei("60"), toWei("35"), toWei("5")];
    const rewardAmount = toWei("100");

    beforeEach(async function () {
      beneficiaries = [nftOwner.address, nftUser.address, thirdParty.address];
      await nft.connect(operator).mint(nftOwner.address, tokenId);
      await rewardToken.connect(operator).transfer(rewardDistributor.address, toWei("10000000"));
    })

    it.skip("Should lend a nft and shares value between beneficiaries in airdroping distribution", async function () {
      const blockNumBefore = await ethers.provider.getBlockNumber();
      const blockBefore = await ethers.provider.getBlock(blockNumBefore);
      const timestampBefore = blockBefore.timestamp;
      await nft.connect(nftOwner).setUserProfitShare(tokenId, nftUser.address, timestampBefore + ONE_DAY, beneficiaries, shares);
      await rewardDistributor.connect(operator).rewardUsers([tokenId], [rewardAmount])
    });
  });

});
