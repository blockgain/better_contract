// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./LibWallet.sol";
import "./ValidatorWallet.sol";

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function mint(address recipient, uint256 amount) external;
    function burn(uint256 amount) external;
    function approve(address spender, uint256 amount) external returns (bool);
}
interface IERC721 {
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
}
interface IERC1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function mint(address to, uint256 id, uint256 amount, bytes calldata _data) external;
    function burn(address to, uint256 id, uint256 amount) external;
}

import "hardhat/console.sol";

contract BetterWallet is Ownable, Validator, ERC1155Holder {

    mapping(bytes => uint256) public processed;

    constructor() {
        __Validator_init_unchained();
    }

    function withdraw(LibWallet.Request memory request, bytes memory signature) external {
        require(owner() == verify(request, signature), "Wrong signature!");
        checkRequest(request, signature);

        if (request.tokenType == 0) {
            payable(request.to).transfer(request.amount);
        } else if (request.tokenType == 1) {
            (IERC20(request.token)).mint(request.to, request.amount);
        } else if (request.tokenType == 2) {
            (IERC20(request.token)).transfer(request.to, request.amount);
        }
        else if (request.tokenType == 3) {
            (IERC20(request.token)).burn(request.amount);
        }
        else if (request.tokenType == 4) {
            (IERC1155(request.token)).mint(request.to, request.id, request.amount, '0x');
        } else if (request.tokenType == 5) {
            (IERC1155(request.token)).safeTransferFrom(address(this), request.to, request.id, request.amount, '0x');
        } else if (request.tokenType == 6) {
            (IERC1155(request.token)).burn(request.to, request.id, request.amount);
        }
    }

    function checkRequest(LibWallet.Request memory request, bytes memory signature)
    internal
    {
        require(processed[signature] == 0, "This transaction already processed!");
        LibWallet.validate(request);
        processed[signature] = 1;
    }
}
