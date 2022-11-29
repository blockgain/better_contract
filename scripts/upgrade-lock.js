// scripts/upgrade-lock.js
const { ethers, upgrades } = require("hardhat");

async function main() {
  const LockV2 = await ethers.getContractFactory("LockV2");
  const lock = await upgrades.upgradeProxy(BOX_ADDRESS, LockV2);
  console.log("LockV2 upgraded");
}

main();
