// // We require the Hardhat Runtime Environment explicitly here. This is optional
// // but useful for running the script in a standalone fashion through `node <script>`.
// //
// // You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// // will compile your contracts, add the Hardhat Runtime Environment's members to the
// // global scope, and execute the script.
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












// // We require the Hardhat Runtime Environment explicitly here. This is optional
// // but useful for running the script in a standalone fashion through `node <script>`.

// // You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// // will compile your contracts, add the Hardhat Runtime Environment's members to the
// // global scope, and execute the script.

// const hre = require("hardhat");

// async function main() {

// const nativeTokenWrapper = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
//   const lockedAmount = hre.ethers.parseEther("0.001");

//   const marketplace = await hre.ethers.deployContract("Marketplace",  [nativeTokenWrapper],
//   );

//   await marketplace.waitForDeployment();

//   console.log(
//     `marketplace  deployed to ${marketplace.target}`
//   );
// }

// // We recommend this pattern to be able to use async/await everywhere
// // and properly handle errors.
// main().catch((error) => {
//   console.error(error);
//   process.exitCode = 1;
// });

// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {
  const erc721Implementation = "0xDa97530F8A0274C84D2d5F2FCD65DC25D663Eac7";
  const platformRecipient = "0xD9792383eF5A1B553e50072A0229d4447143fD82";
  const platfromFees = 500;
  const operator = "0xB571194D8EC3f82C523296E140011cd06e374E56";
  const erc721DropFactory = await hre.ethers.deployContract(
    "ERC721DropFactory",
    [erc721Implementation, platformRecipient, platfromFees, operator]
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
