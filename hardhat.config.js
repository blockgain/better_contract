require('dotenv').config()

require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

const privateKey = '2aa78830ce8a8e1f92c7ca48806ee2aeb97791be4b303040cfa1d55117cdd773'

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      forking: {
        url: "https://sepolia.infura.io/v3/b4b652cc9de242029fd57c433dbf311c",
        blockNumber: 4010597,
      },
      accounts: [
        {
          privateKey,
          balance: '100000000000000000000000000000'
        }
      ]
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org`,
      accounts: []
    },
  }
}
