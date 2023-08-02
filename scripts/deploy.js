// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

async function main() {

  const BetterWallet = await hre.ethers.getContractFactory("BetterWallet");
  const walletContract = await BetterWallet.deploy();
  console.log('wallet', walletContract.address);

  const BTB = await hre.ethers.getContractFactory("BTB");
  const btbContract = await BTB.deploy();
  console.log('BTB', btbContract.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
