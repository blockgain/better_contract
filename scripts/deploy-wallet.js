const hre = require("hardhat");

async function main() {
    const BetterWallet = await hre.ethers.getContractFactory("BetterWallet");
    const walletContract = await BetterWallet.deploy({});
    console.log("BetterWallet deployed to address:", walletContract.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
