// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
library LibWallet {

    string private constant REQUEST_TYPE = "Request(address to,address token,uint256 id,uint256 amount,uint8 tokenType,uint256 start,uint256 end)";
    bytes32 constant REQUEST_TYPEHASH = keccak256(abi.encodePacked(REQUEST_TYPE));

    struct Request {
        address to;
        address token;
        uint256 id;
        uint256 amount;
        uint8 tokenType;
        uint256 start;
        uint256 end;
    }

    function hash(LibWallet.Request memory request) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                REQUEST_TYPEHASH,
                request.to,
                request.token,
                request.id,
                request.amount,
                request.tokenType,
                request.start,
                request.end
            )
        );
    }

    function validate(LibWallet.Request memory request) internal view {
        require(request.start == 0 || request.start < block.timestamp, "Request start validation failed");
        require(request.end == 0 || request.end > block.timestamp, "Request end validation failed");
    }
}

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
abstract contract Validator {
    using ECDSA for bytes32;

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

interface IERC20 {
    function mint(address to, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;

}
interface IERC721 {
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function mint(address to, uint256 id) external;
    function mint(address to, uint256 id, bytes calldata _data) external;
    function burn(address to, uint256 id) external;
}
interface IERC1155 {
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;
    function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data) external;
    function mint(address to, uint256 id, uint256 amount, bytes calldata _data) external;
    function burn(address to, uint256 id, uint256 amount) external;
    function transferOwnership(address newOwner) external;
}

contract BetterWallet is Ownable, Validator, ERC1155Holder {

    mapping(bytes => uint256) public processed;

    constructor() {
        __Validator_init_unchained();
    }

    event Withdraw(LibWallet.Request request, bytes signature);

    function withdraw(LibWallet.Request memory request, bytes memory signature) external {
        require(owner() == verify(request, signature), "Wrong signature!");
        checkRequest(request, signature);

        if (request.tokenType == 0) {
            payable(request.to).transfer(request.amount);
        } else if (request.tokenType == 1) {
            (IERC20(request.token)).mint(request.to, request.amount);
        } else if (request.tokenType == 2) {
            (IERC20(request.token)).transfer(request.to, request.amount);
        } else if (request.tokenType == 3) {
            (IERC20(request.token)).burn(request.amount);
        } else if (request.tokenType == 4) {
            (IERC1155(request.token)).mint(request.to, request.id, request.amount, '0x');
        } else if (request.tokenType == 5) {
            (IERC1155(request.token)).safeTransferFrom(address(this), request.to, request.id, request.amount, '0x');
        } else if (request.tokenType == 6) {
            (IERC1155(request.token)).burn(request.to, request.id, request.amount);
        } else if (request.tokenType == 7) {
            (IERC1155(request.token)).transferOwnership(request.to);
        } else if (request.tokenType == 8) {
            (IERC721(request.token)).mint(request.to, request.id);
        } else if (request.tokenType == 9) {
            (IERC721(request.token)).safeTransferFrom(address(this), request.to, request.id);
        } else if (request.tokenType == 10) {
            (IERC721(request.token)).burn(request.to, request.id);
        }

        emit Withdraw(request, signature);
    }

    function checkRequest(LibWallet.Request memory request, bytes memory signature)
    internal
    {
        require(processed[signature] == 0, "This transaction already processed!");
        LibWallet.validate(request);
        processed[signature] = 1;
    }

    event Deposit(address, uint256);
    function deposit() payable external {
        emit Deposit(msg.sender, msg.value);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}
