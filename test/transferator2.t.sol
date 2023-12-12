// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ds-test/test.sol";
import "../src/Transferator2.sol";
import "./mocks/MockERC20.sol";

contract Transferator2Test is DSTest {
    Transferator2 transferator2;
    MockERC20 token;

    function setUp() public {
        token = new MockERC20();
        transferator2 = new Transferator2(address(token));
        transferator2.setSaleState(1);
    }

    function test_TransferTokens() public {
        uint256 amount = 1e18;
        token.approve(address(transferator2), amount);
        transferator2.transferTokens(amount);
        assertEq(token.balanceOf(address(transferator2)), amount);
        
    }
}
