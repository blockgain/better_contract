pragma solidity ^0.8.0;

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
