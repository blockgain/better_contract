// scripts/create-lock.js
const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {
  const BetterFan = await ethers.getContractFactory("BetterFan");
  const hardhatToken = await BetterFan.deploy();


}

main();
