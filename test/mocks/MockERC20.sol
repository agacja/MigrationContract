// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "solmate/auth/Owned.sol";

contract MockERC20 is ERC20, Owned(msg.sender){
    constructor() ERC20("MyToken", "MT") {
        _mint(msg.sender, 1000000 * (10 ** uint256(decimals())));
    }
}