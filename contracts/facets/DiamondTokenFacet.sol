// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TokenStorage } from "../libraries/LibAppStorage.sol";
import { LibERC721 } from "../libraries/LibERC721.sol";
import { IERC721Metadata } from "../interfaces/IERC721Metadata.sol";
import { IERC721 } from "../interfaces/IERC721.sol";

// import "../interfaces/IERC721.sol";

error InsufficientAllowance();
error NotApprovedOrOwner();

contract DiamondTokenFacet is IERC721Metadata { // , 
    // TokenStorage internal s;
    TokenStorage s;

   function name() external pure  returns(string memory) {
       return "Diamond Token";
   }

   function symbol() external pure returns(string memory) {
       return "DTKN";
   }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(LibERC721.ownerOf(s, tokenId) != address(0), "ERC721Metadata: URI query for nonexistent token");
        return s.tokenURIs[tokenId];
    }

    function balanceOf(address owner) external view override returns (uint256 balance) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return s.balances[owner];
    }

    function ownerOf(uint256 tokenId) external view override returns (address owner) {
        return LibERC721.ownerOf(s, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external override {
        require(LibERC721.isApprovedOrOwner(s, msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, data);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external override {
        // safeTransferFrom(from, to, tokenId, "");
        _safeTransfer(from, to, tokenId, "");
    }


    function transferFrom(address from, address to, uint256 tokenId) external override {
        require(LibERC721.isApprovedOrOwner(s, msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        LibERC721.transfer(s, from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external override {
        address owner = LibERC721.ownerOf(s, tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );
        LibERC721.approve(s, owner, to, tokenId);
         emit Approval(owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external override {
        LibERC721.setApprovalForAll(s, msg.sender, operator, approved);
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function getApproved(uint256 tokenId) external view override returns (address) {
        require(LibERC721.ownerOf(s, tokenId) != address(0), "ERC721: approved query for nonexistent token");
        return s.tokenApprovals[tokenId];
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        return s.operatorApprovals[owner][operator];
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        LibERC721.transfer(s, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // Additional functions for minting and burning can be added here
    function mint(address to, uint256 tokenId) external {
        // Add access control here
        LibERC721.mint(s, to, tokenId);
        emit Transfer(address(0), to, tokenId);
    }

    function burn(uint256 tokenId) external {
        require(LibERC721.isApprovedOrOwner(s, msg.sender, tokenId), "ERC721: caller is not owner nor approved");
        address owner = LibERC721.ownerOf(s, tokenId);
        LibERC721.transfer(s, owner, address(0), tokenId);
         emit Transfer(owner, address(0), tokenId);
    }

    // function supportsInterface(bytes4 interfaceId) external view override returns (bool) {
    //     return interfaceId == IERC721Metadata.interfaceId || super.supportsInterface(interfaceId);
    // }
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
