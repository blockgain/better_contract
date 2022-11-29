// scripts/create-lock.js
const hre = require("hardhat");
const { ethers, upgrades } = require("hardhat");

async function main() {
  const BetterFan = await ethers.getContractFactory("BetterFan");
  const deployContract = await BetterFan.deploy();

  const chainId = hre.network.config.chainId

  const domain = {
    name: "Better Fan",
    version: '1',
    verifyingContract: deployContract.address,
    chainId: chainId,
  };

  const types = {
    Claim: [
      {name: 'account', type: 'address'},
      {name: 'id', type: 'uint256'},
      {name: 'amount', type: 'uint256'},
      {name: 'start', type: 'uint256'},
      {name: 'end', type: 'uint256'}
    ]
  };

  const value = {
    account: '0x4ce1690766F728E5640054476C6e0E3257aEfe2f',
    id: 1,
    amount: 1,
    start: Date.now(),
    end: Date.now()
  }


  const [signer] = await ethers.getSigners();
  const signature = await signer._signTypedData(domain, types, value);

  console.log(signature)

  const check = await deployContract.claim(value, signature)

  console.log(check)

}

main();
