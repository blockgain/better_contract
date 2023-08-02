// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract BetterFanCard is ERC721, Ownable, ERC721Burnable {
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public totalSupply;
    uint256 public price;
    string public baseURI;

    using Strings for uint256;

    constructor() ERC721("BetterFanCard", "BFC") {
        setBaseURI("https://api.better.fan/assets/");
        price = 0.8 ether;
    }

    function contractURI() public view returns (string memory) {
        return "https://api.better.fan/metadata";
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setPrice(uint256 newPrice) public onlyOwner {
        price = newPrice;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "Token does not exist");
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function mint() public payable {
        require(msg.value >= price, "Insufficient payment");
        require(totalSupply < MAX_SUPPLY, "Max supply reached");
        _safeMint(_msgSender(), totalSupply + 1);
        totalSupply++;
    }

    function mint(address to, uint256 tokenId) public onlyOwner {
        _safeMint(to, tokenId);
        totalSupply++;
    }


}
