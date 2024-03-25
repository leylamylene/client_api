const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721DropFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721DropFactory() {
    const erc721Implementation = "0xDa97530F8A0274C84D2d5F2FCD65DC25D663Eac7";
    const platformRecipient = "0xD9792383eF5A1B553e50072A0229d4447143fD82";
    const platfromFees = 500;
    const operator = "0xB571194D8EC3f82C523296E140011cd06e374E56";

    // Contracts are deployed using the first signer/account by default

    const ERC721DropFactory = await ethers.getContractFactory(
      "ERC721DropFactory"
    );
    const eRC721DropFactory = await ERC721DropFactory.deploy(
      erc721Implementation,
      platformRecipient,
      platfromFees,
      operator,
    );

    return { eRC721DropFactory };
  }

  describe("Deployment", function () {
    it("Should set the rightimplementation address", async function () {
      const impl_address = "0xDa97530F8A0274C84D2d5F2FCD65DC25D663Eac7";
      const { eRC721DropFactory } =
        await deployERC721DropFactory();

      expect(await eRC721DropFactory.implementationAddress()).to.equal(impl_address);
    });

    it("Should set the right owner", async function () {
      const [owner] = await ethers.getSigners();
      const { eRC721DropFactory } =
        await deployERC721DropFactory();

      expect(await eRC721DropFactory.owner()).to.equal(owner.address);
    });
  });
});
