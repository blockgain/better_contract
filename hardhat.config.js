require('dotenv').config()

require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

const ALCHEMY_API_KEY = process.env.ALCHEMY_API_KEY;
// Beware: NEVER put real Ether into testing accounts
const GOERLI_PRIVATE_KEY = process.env.GOERLI_PRIVATE_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  networks: {
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/${ALCHEMY_API_KEY}`,
      accounts: [GOERLI_PRIVATE_KEY]
    },
    bsc: {
      url: `https://bsc-dataseed.binance.org`,
      accounts: [GOERLI_PRIVATE_KEY]
    },
  }
}
