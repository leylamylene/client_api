// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

const nativeTokenWrapper = "0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2";
  const lockedAmount = hre.ethers.parseEther("0.001");

  const marketplace = await hre.ethers.deployContract("marketplace",  [nativeTokenWrapper],
  );

  await marketplace.waitForDeployment();

  console.log(
    `marketplace  deployed to ${marketplace.target}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
