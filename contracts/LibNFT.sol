pragma solidity ^0.8.0;

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
