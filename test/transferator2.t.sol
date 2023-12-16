// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "ds-test/test.sol";
import "../src/Transferator2.sol";
import "./mocks/MockERC20.sol";
import "./mocks/MockERC721.sol";
import "forge-std/Test.sol";

contract Transferator2Test is DSTest {
    Transferator2 transferator2;
    MockERC20 token;
    MockERC721 nft;
    address receiver = 0x1e526ecc6CDcaB653823968b58056Ad5b438C92b;
    address ownerAddress = address.this;

    function setUp() public {
        token = new MockERC20();
        nft = new MockERC721();

        transferator2 = new Transferator2(address(token), address(nft));
        transferator2.setSaleState(1);
    }

    function test_TransferTokens() public {
        uint256 amount = 1e18;
        token.approve(address(transferator2), amount);
        transferator2.transferTokens(amount);
        assertEq(token.balanceOf(address(transferator2)), amount);
        assertEq(transferator2.totalERC20Deposited(address(this)), amount);
    }

    function testTransferNFTs() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            nft.approve(address(transferator2), tokenIds[i]);
        }
        transferator2.transferNFTs(tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(nft.ownerOf(tokenIds[i]), address(transferator2));
        }
        assertEq(transferator2.totalERC721Deposited(address(this)), 2);
    }

  function testWithdrawTokens() public {
     
        payable(address(transferator2)).transfer(1 ether);

        uint256 initialERC20Balance = mockERC20.balanceOf(receiver);
        uint256 initialETHBalance = receiver.balance;

        vm.prank(ownerAddress);
        transferator2.withdrawTokens();

        assertEq(MockERC20.balanceOf(receiver), initialERC20Balance + 1000 ether);
        assertEq(receiver.balance, initialETHBalance + 1 ether);
    }

    function testWithdrawNFTs() public {
        uint256[] memory tokenIds = new uint256[](1);
        tokenIds[0] = 1; 

        vm.prank(ownerAddress);
    transferator2.withdrawNFTs(tokenIds);

        assertEq(MockERC721.ownerOf(1), receiver);
    }
}






