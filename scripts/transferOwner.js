// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const moment = require('moment')

async function main() {
    const [owner, otherAccount] = await hre.ethers.getSigners();
    const BetterWallet = await hre.ethers.getContractFactory("BetterWallet");
    const contract = BetterWallet.attach('0xc720FE3E061e5d222C77e9C9b81d275c6dD9b5bf')

    const chainId = await contract.signer.getChainId()

    async function signData(data) {
        const domain = {
            name: 'Better Fan Wallet',
            version: '1',
            verifyingContract: contract.address,
            chainId
        }
        const types = {
            Request: [
                { name: 'to', type: 'address' },
                { name: 'token', type: 'address' },
                { name: 'id', type: 'uint256' },
                { name: 'amount', type: 'uint256' },
                { name: 'tokenType', type: 'uint8' },
                { name: 'start', type: 'uint256' },
                { name: 'end', type: 'uint256' },
            ],
        };
        return await owner._signTypedData(domain, types, data);
    }
    const request = {
        to: '0xA882E64BEFe25E0B977f7B0957f38EdA853849D1',
        token: '0x324045d9E061b712eA922bc7C4eDb7ed2a4bDaa2', // BTB, BFF, BETTERFAN COLLECTION
        id: 0,
        amount: 0,
        tokenType: 7,
        start: moment().subtract(1, 'minutes').unix(),
        end: moment().add(1, 'days').unix(),
    }
    const signature = await signData(request)

    console.log(Object.values(request), ',', signature)
    const tx = await contract.withdraw(request, signature)

    console.log(tx)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
