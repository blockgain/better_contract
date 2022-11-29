// scripts/create-lock.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const BetterFan = await ethers.getContractFactory("BetterFan");
  const lock = await upgrades.deployProxy(BetterFan, [42]);
  await lock.deployed();
  console.log("BetterFan deployed to:", lock.address);
}

main();
