// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "solmate/auth/Owned.sol";

contract MockERC721 is ERC721, Owned {

    constructor() ERC721("MyERC721", "M721") Owned(msg.sender) {
        for (uint i = 1; i <= 5; i++) {
            _mint(msg.sender, i);
        }
    }

}