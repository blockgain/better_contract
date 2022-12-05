// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./LibNFT.sol";
import "./Validator.sol";

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
