// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MerkleFacet is Ownable(msg.sender) {
    bytes32 public merkleRoot;
    mapping(address => bool) public claimed;

    event Claimed(address indexed claimant, uint256 tokenId);

    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        merkleRoot = _merkleRoot;
    }

    function claim(bytes32[] calldata _merkleProof, uint256 _tokenId) external {
        require(!claimed[msg.sender], "Address has already claimed");
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, _tokenId));
        require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), "Invalid proof");

        claimed[msg.sender] = true;
        
        (bool success, ) = address(this).delegatecall(
            abi.encodeWithSignature("mint(address)", msg.sender)
        );
        require(success, "Minting failed");

        emit Claimed(msg.sender, _tokenId);
    }
}