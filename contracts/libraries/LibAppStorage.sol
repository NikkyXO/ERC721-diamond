// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


struct TokenStorage {
    uint256 initialized;
    uint256 totalSupply;
    string name;
    string symbol;
    mapping(uint256 => address) owners;
    mapping(address => uint256) balances;
    mapping(uint256 => address) tokenApprovals;
    mapping(address => mapping(address => bool)) operatorApprovals;
    mapping(uint256 => string) tokenURIs;
}

library LibAppStorage {
   function tokenStorage() internal pure returns(TokenStorage storage ts) {
       assembly {
           ts.slot := 0
       }
   }
}