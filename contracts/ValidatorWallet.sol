pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./LibWallet.sol";
import "hardhat/console.sol";

abstract contract Validator {
    using ECDSA for bytes32;

    //********** EIP-712 **********
    string public constant name = "Better Fan Wallet";
    string public constant version = "1";
    uint256 private _chainId;

    struct EIP712Domain {
        string name;
        string version;
        uint256 chainId;
        address verifyingContract;
    }

    string private constant EIP712_DOMAIN_TYPE = "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)";
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = keccak256(abi.encodePacked(EIP712_DOMAIN_TYPE));

    bytes32 DOMAIN_SEPARATOR;

    //********** EIP-712 **********

    function __Validator_init_unchained() public {
        _chainId = block.chainid;
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                _chainId,
                address(this)
            )
        );
    }

    function verify(LibWallet.Request memory request, bytes memory _signature)
    public
    view
    returns (address)
    {
        bytes32 hash = LibWallet.hash(request);
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, hash).recover(_signature);
    }
}
