// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

library LibNFT {

    string private constant REQUEST_TYPE = "Request(address account,uint256 id,uint256 amount,uint256 start,uint256 end)";
    bytes32 constant REQUEST_TYPEHASH = keccak256(abi.encodePacked(REQUEST_TYPE));

    struct Request {
        address account;
        uint256 id;
        uint256 amount;
        uint256 start;
        uint256 end;
    }

    function hash(LibNFT.Request memory request) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                REQUEST_TYPEHASH,
                request.account,
                request.id,
                request.amount,
                request.start,
                request.end
            )
        );
    }

    function validate(LibNFT.Request memory request) internal view {
        require(request.start == 0 || request.start < block.timestamp, "Request start validation failed");
        require(request.end == 0 || request.end > block.timestamp, "Request end validation failed");
    }
}
abstract contract Validator {
    using ECDSA for bytes32;

    //********** EIP-712 **********
    string public constant name = "Better Fan";
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

    function verify(LibNFT.Request memory request, bytes memory _signature)
    public
    view
    returns (address)
    {
        bytes32 hash = LibNFT.hash(request);
        return ECDSA.toTypedDataHash(DOMAIN_SEPARATOR, hash).recover(_signature);
    }
}

contract BetterFan is ERC1155, Ownable, Pausable, ERC1155Burnable, Validator {

    mapping(bytes => uint256) public processed;

    function contractURI() public view returns (string memory) {
        return "https://api.better.fan/metadata";
    }

    constructor() ERC1155("https://api.better.fan/tokens/0x{id}.json") {
        __Validator_init_unchained();
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function signMint(LibNFT.Request memory request, bytes memory signature) external whenNotPaused {
        require(owner() == verify(request, signature), "Wrong signature!");
        checkRequest(request, signature);

        _mint(request.account, request.id, request.amount, new bytes(0));
    }

    function signMintBatch(LibNFT.Request[] memory requests, bytes[] memory signatures) external whenNotPaused {
        for(uint i=0; i<requests.length; i++){
            require(owner() == verify(requests[i], signatures[i]), "Wrong signature!");
            checkRequest(requests[i], signatures[i]);
            _mint(requests[i].account, requests[i].id, requests[i].amount, new bytes(0));
        }
    }

    function checkRequest(LibNFT.Request memory request, bytes memory signature)
    internal
    {
        require(processed[signature] == 0, "This transaction already processed!");
        LibNFT.validate(request);
        processed[signature] = 1;
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data)
    public
    onlyOwner
    {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    public
    onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    internal
    whenNotPaused
    override
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
