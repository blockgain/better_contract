// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

import "./LibClaim.sol";
import "./Validator.sol";

contract BetterFan is ERC1155, Ownable, Pausable, ERC1155Burnable, Validator {

    mapping(bytes => uint256) public processed;

    function contractURI() public view returns (string memory) {
        return "https://dev-api.better.fan/metadata";
    }

    constructor() ERC1155("https://dev-api.better.fan/tokens/0x{id}.json") {
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

    function claim(LibClaim.Claim memory claim, bytes memory signature) external whenNotPaused {
        require(owner() == verify(claim, signature), "Wrong signature!");
        checkRequest(claim, signature);

        _mint(claim.account, claim.id, claim.amount, new bytes(0));
    }

    function claimBatch(LibClaim.Claim[] memory claims, bytes[] memory signatures) external whenNotPaused {
        for(uint i=0; i<claims.length; i++){
            require(owner() == verify(claims[i], signatures[i]), "Wrong signature!");
            checkRequest(claims[i], signatures[i]);
            _mint(claims[i].account, claims[i].id, claims[i].amount, new bytes(0));
        }
    }

    function checkRequest(LibClaim.Claim memory claim, bytes memory signature)
    internal
    {
        require(processed[signature] == 0, "This transaction already processed!");
        LibClaim.validate(claim);
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
