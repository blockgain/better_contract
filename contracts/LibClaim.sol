pragma solidity ^0.8.0;

library LibClaim {

    string private constant CLAIM_TYPE = "Claim(address account,uint256 id,uint256 amount,uint256 start,uint256 end)";
    bytes32 constant CLAIM_TYPEHASH = keccak256(abi.encodePacked(CLAIM_TYPE));

    struct Claim {
        address account;
        uint256 id;
        uint256 amount;
        uint256 start;
        uint256 end;
    }

    function hash(LibClaim.Claim memory claim) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                CLAIM_TYPEHASH,
                claim.account,
                claim.id,
                claim.amount,
                claim.start,
                claim.end
            )
        );
    }

    function validate(LibClaim.Claim memory claim) internal view {
        require(claim.start == 0 || claim.start < block.timestamp, "Claim start validation failed");
        require(claim.end == 0 || claim.end > block.timestamp, "Claim end validation failed");
    }
}
