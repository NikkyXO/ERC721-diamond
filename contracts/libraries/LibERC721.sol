// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { TokenStorage } from "./LibAppStorage.sol";

library LibERC721 {
    error InvalidAddress();
    error NonexistentToken();
    error NotTokenOwner();
    error NotApprovedOrOwner();
    error TokenAlreadyMinted();

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function mint(TokenStorage storage ts, address _to, uint256 _tokenId) internal {
        if(_to == address(0)) revert InvalidAddress();
        if(ts.owners[_tokenId] != address(0)) revert TokenAlreadyMinted();

        ts.owners[_tokenId] = _to;
        ts.balances[_to] += 1;

        emit Transfer(address(0), _to, _tokenId);
    }

    function transfer(TokenStorage storage ts, address _from, address _to, uint256 _tokenId) internal {
        if(_from == address(0)) revert InvalidAddress();
        if(_to == address(0)) revert InvalidAddress();
        if(ts.owners[_tokenId] != _from) revert NotTokenOwner();

        // Clear approvals
        delete ts.tokenApprovals[_tokenId];

        ts.owners[_tokenId] = _to;
        ts.balances[_from] -= 1;
        ts.balances[_to] += 1;

        emit Transfer(_from, _to, _tokenId);
    }

    function approve(TokenStorage storage ts, address _owner, address _approved, uint256 _tokenId) internal {
        if(_owner == address(0)) revert InvalidAddress();
        if(_approved == address(0)) revert InvalidAddress();
        if(ts.owners[_tokenId] != _owner) revert NotTokenOwner();

        ts.tokenApprovals[_tokenId] = _approved;

        emit Approval(_owner, _approved, _tokenId);
    }

    function setApprovalForAll(TokenStorage storage ts, address _owner, address _operator, bool _approved) internal {
        if(_owner == address(0)) revert InvalidAddress();
        if(_operator == address(0)) revert InvalidAddress();

        ts.operatorApprovals[_owner][_operator] = _approved;

        emit ApprovalForAll(_owner, _operator, _approved);
    }

    function isApprovedOrOwner(TokenStorage storage ts, address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ts.owners[_tokenId];
        return (_spender == owner || ts.tokenApprovals[_tokenId] == _spender || ts.operatorApprovals[owner][_spender]);
    }

    function ownerOf(TokenStorage storage ts, uint256 _tokenId) internal view returns (address) {
        address owner = ts.owners[_tokenId];
        if(owner == address(0)) revert NonexistentToken();
        return owner;
    }
}


