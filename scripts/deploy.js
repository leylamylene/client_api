
// const hre = require("hardhat");

// async function main() {
//   const erc721Drop = await hre.ethers.deployContract("ERC721Drop");

//   await erc721Drop.waitForDeployment();

//   console.log(`erc721 drop deployed to ${erc721Drop.target}`);
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });


// const hre = require("hardhat");

// async function main() {
//   const nativeTokenWrapper = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";

//   const marketplace = await hre.ethers.deployContract("Marketplace", [
//     nativeTokenWrapper,
//   ]);

//   await marketplace.waitForDeployment();

//   console.log(`marketplace  deployed to ${marketplace.target}`);
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });


const hre = require("hardhat");

async function main() {
  const erc721Implementation = "0x042aE84cE221141486346D9ee5697167eE9044d8";
  const erc721DropFactory = await hre.ethers.deployContract(
    "ERC721DropFactory",
    [erc721Implementation]
  );

  await erc721DropFactory.waitForDeployment();

  console.log(`erc721DropFactory  deployed to ${erc721DropFactory.target}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
