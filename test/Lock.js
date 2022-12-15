const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

const tokens = {
  chain: '0x0000000000000000000000000000000000000000',
  btb: '0x0000000000000000000000000000000000000000',
  bff: '0x0000000000000000000000000000000000000000',
}

function toEther(number) {
  return hre.ethers.utils.parseEther(number.toString());
}


describe("BetterWallet", function () {
  async function deployWallet() {
    const [owner, otherAccount] = await ethers.getSigners();
    const BetterWallet = await ethers.getContractFactory("BetterWallet");
    const walletContract = await BetterWallet.deploy();
    async function signData(data) {
      const domain = {
        name: 'Better Fan Wallet',
        version: '1',
        verifyingContract: walletContract.address,
        chainId: 31337,
      };

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
    return { walletContract, owner, otherAccount, signData };
  }
  async function deployNFT(factory = 'BetterFan', address) {
    const [owner, otherAccount] = await ethers.getSigners();
    const BetterWallet = await ethers.getContractFactory(factory);
    const nftContract = await BetterWallet.deploy();
    async function signData(data) {
      const domain = {
        name: 'Better Fan',
        version: '1',
        verifyingContract: nftContract.address,
        chainId: 31337,
      };

      const types = {
        Request: [
          { name: 'account', type: 'address' },
          { name: 'id', type: 'uint256' },
          { name: 'amount', type: 'uint256' },
          { name: 'start', type: 'uint256' },
          { name: 'end', type: 'uint256' },
        ],
      };

      return await owner._signTypedData(domain, types, data);
    }
    return { nftContract, owner, otherAccount, signData };
  }
  async function deployERC20(factory = 'BTB', address) {
    const [owner, otherAccount] = await ethers.getSigners();
    const BetterWallet = await ethers.getContractFactory(factory);
    const btbContract = await BetterWallet.deploy();
    async function signData(data) {
      const domain = {
        name: 'Better Fan',
        version: '1',
        verifyingContract: btbContract.address,
        chainId: 31337,
      };

      const types = {
        Request: [
          { name: 'account', type: 'address' },
          { name: 'id', type: 'uint256' },
          { name: 'amount', type: 'uint256' },
          { name: 'start', type: 'uint256' },
          { name: 'end', type: 'uint256' },
        ],
      };

      return await owner._signTypedData(domain, types, data);
    }
    return { btbContract, owner, otherAccount, signData };
  }

  beforeEach(async () => {
    let wal = await deployWallet();
    owner = wal.owner
    otherAccount = wal.otherAccount
    walletContract = wal.walletContract
    signData = wal.signData
    const con2 = await deployNFT();
    nftContract = con2.nftContract
    // owner set
    await nftContract.transferOwnership(walletContract.address)

    const con3 = await deployERC20();
    btbContract = con3.btbContract
    // owner set
    await btbContract.transferOwnership(walletContract.address)
  });

  describe("Transfer", function () {

    it("Chain token transfer", async function () {
      const {owner, walletContract, signData} = await loadFixture(deployWallet);

      const lastBlock = await time.latest()

      const request = {
        to: owner.address,
        token: tokens['chain'],
        id: 0,
        amount: toEther('1'),
        tokenType: 0,
        start: lastBlock,
        end: lastBlock * 2,
      }

      const signature = await signData(request)
      await expect(walletContract.withdraw(request, signature)).to.be.reverted;
    });


    it("ERC20", async function () {
      const lastBlock = await time.latest()

      // Mint
      const request = {
        to: walletContract.address,
        token: btbContract.address,
        id: 0,
        amount: 10,
        tokenType: 1,
        start: lastBlock,
        end: lastBlock * 2,
      }
      const signature = await signData(request)
      const _beforeBalance = (await btbContract.balanceOf(request.to)).toNumber()
      await walletContract.withdraw(request, signature)
      const _newBalance = (await btbContract.balanceOf(request.to)).toNumber()
      await expect(_newBalance).equal(_beforeBalance+request.amount);

      // Transfer
      const _request = {
        to: otherAccount.address,
        token: btbContract.address,
        id: 0,
        amount: 1,
        tokenType: 2,
        start: lastBlock,
        end: lastBlock * 2,
      }
      const _signature = await signData(_request)
      const __beforeBalance = (await btbContract.balanceOf(_request.to)).toNumber()
      await walletContract.withdraw(_request, _signature)
      const __newBalance = (await btbContract.balanceOf(_request.to)).toNumber()
      await expect(__newBalance).equal(__beforeBalance+_request.amount);


      // BURN
      const burn_request = {
        to: otherAccount.address,
        token: btbContract.address,
        id: 0,
        amount: 1,
        tokenType: 3,
        start: lastBlock,
        end: lastBlock * 2,
      }
      const burn_signature = await signData(burn_request)
      const burn_beforeBalance = (await btbContract.balanceOf(walletContract.address)).toNumber()
      await walletContract.withdraw(burn_request, burn_signature)
      const burn_newBalance = (await btbContract.balanceOf(walletContract.address)).toNumber()
      await expect(burn_newBalance).equal(burn_beforeBalance-burn_request.amount);
    });
    it("ERC155", async function () {
      const lastBlock = await time.latest()

      // Mint
      const request = {
        to: walletContract.address,
        token: nftContract.address,
        id: 1,
        amount: 1,
        tokenType: 4,
        start: lastBlock,
        end: lastBlock * 2,
      }
      const signature = await signData(request)
      const _beforeBalance = (await nftContract.balanceOf(request.to, request.id)).toNumber()
      await walletContract.withdraw(request, signature)
      const _newBalance = (await nftContract.balanceOf(request.to, request.id)).toNumber()
      await expect(_newBalance).equal(_beforeBalance+request.amount);

      // Transfer
      const _request = {
        to: otherAccount.address,
        token: nftContract.address,
        id: 1,
        amount: 1,
        tokenType: 5,
        start: lastBlock,
        end: lastBlock * 2,
      }
      const _signature = await signData(_request)
      const __beforeBalance = (await nftContract.balanceOf(_request.to, _request.id)).toNumber()
      await walletContract.withdraw(_request, _signature)
      const __newBalance = (await nftContract.balanceOf(_request.to, _request.id)).toNumber()
      await expect(__newBalance).equal(__beforeBalance+_request.amount);
    });
  });


});
