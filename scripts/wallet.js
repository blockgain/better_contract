// scripts/create-lock.js
const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {
  const BetterFan = await ethers.getContractFactory("BetterFan");
  const wallet = await BetterFan.deploy();

  console.log(wallet)
}

main();
