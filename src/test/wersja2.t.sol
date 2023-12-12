// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ds-test/test.sol";
import "../Wersja2.sol";
import "./mocks/MockERC20.sol";

contract Wersja2Test is DSTest{


   Wersja2 wersja2;
   MockERC20 token;

    function setUp() public {
        token = new MockERC20();
        wersja2 = new Wersja2(address(token));
        wersja2.setSaleState(1);

 }

function testTransferTokens() public {
  
    uint256 amount = 1e18;
   // address user = address(this);

    token.approve(address(wersja2), amount);
    wersja2.transferTokens(amount);
    assertEq(token.balanceOf(address(wersja2)), amount);



}
}
