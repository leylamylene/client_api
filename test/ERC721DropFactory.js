const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("ERC721DropFactory", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721DropFactory() {
    const impl_address = "0x042aE84cE221141486346D9ee5697167eE9044d8";

    // Contracts are deployed using the first signer/account by default

    const ERC721DropFactory = await ethers.getContractFactory(
      "ERC721DropFactory"
    );
    const eRC721DropFactory = await ERC721DropFactory.deploy(impl_address);

    return { eRC721DropFactory };
  }

  describe("Deployment", function () {
    it("Should set the right implementation address", async function () {
      const impl_address = "0x042aE84cE221141486346D9ee5697167eE9044d8";
      const { eRC721DropFactory } = await deployERC721DropFactory();

      expect(await eRC721DropFactory.implementationAddress()).to.equal(
        impl_address
      );
    });

    it("Should set the right owner", async function () {
      const [owner] = await ethers.getSigners();
      const { eRC721DropFactory } = await deployERC721DropFactory();

      expect(await eRC721DropFactory.owner()).to.equal(owner.address);
    });
  });

  describe("Clone", function () {
    it("The return clone should have the right primary recipient address  ", async function () {
      const marketplaceOperator = "0x925517C15f4Ec1cD49E7f26a9130ba1cFCFA35f4";
      const [owner] = await ethers.getSigners();
      const { eRC721DropFactory } = await deployERC721DropFactory();
      const tx = await eRC721DropFactory
        .connect(owner)
        .createClone("my first collection", "myc", marketplaceOperator, {
          value: ethers.parseUnits("0.0001", "ether"),
        });

      const receipt = await tx.wait();
      expect(receipt.events[0].args.newERC721Drop).to.equal(bob.address);
      expect(
        eRC721DropFactory
          .connect(owner)
          .createClone("my first collection", "myc", marketplaceOperator, {
            value: ethers.parseUnits("0.0001", "ether"),
          })
      ).not.to.be.reverted;
    });
  });
});
