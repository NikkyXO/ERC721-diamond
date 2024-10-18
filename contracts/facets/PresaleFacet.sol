// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract PresaleFacet is Ownable(msg.sender) {
    uint256 public constant PRICE_PER_TOKEN = 0.033333333333333333 ether; // 1 ETH = 30 NFTs
    uint256 public constant MIN_PURCHASE = 0.01 ether;
    bool public presaleActive = false;

    event TokensPurchased(address indexed buyer, uint256 amount);

    function togglePresale() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function buyTokens() external payable {
        require(presaleActive, "Presale is not active");
        require(msg.value >= MIN_PURCHASE, "Must purchase at least 0.01 ETH worth of tokens");

        uint256 tokenAmount = msg.value / PRICE_PER_TOKEN;
        require(tokenAmount > 0, "Not enough ETH sent");

        for (uint256 i = 0; i < tokenAmount; i++) {
            // Call the mint function from ERC721Facet
            (bool success, ) = address(this).delegatecall(
                abi.encodeWithSignature("mint(address)", msg.sender)
            );
            require(success, "Minting failed");
        }

        emit TokensPurchased(msg.sender, tokenAmount);

        // Refund excess ETH
        uint256 excess = msg.value - (tokenAmount * PRICE_PER_TOKEN);
        if (excess > 0) {
            payable(msg.sender).transfer(excess);
        }
    }

    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }
}