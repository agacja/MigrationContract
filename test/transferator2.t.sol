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
    
     uint256 initialETHBalance = address(receiver).balance;

   
    function setUp() public {
        token = new MockERC20();
        nft = new MockERC721();

        transferator2 = new Transferator2(address(token), address(nft));
        transferator2.setSaleState(1);
    }

    function test_migrateTokens() public {
        uint256 amount = 1e18;
        token.approve(address(transferator2), amount);
        transferator2.migrateTokens(amount);
        assertEq(token.balanceOf(address(transferator2)), amount);
        assertEq(transferator2.totalERC20Migrated(address(this)), amount);
    }

    function test_migrateNFTs() public {
        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = 1;
        tokenIds[1] = 2;

        for (uint256 i = 0; i < tokenIds.length; i++) {
            nft.approve(address(transferator2), tokenIds[i]);
        }
        transferator2.migrateNFTs(tokenIds);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            assertEq(nft.ownerOf(tokenIds[i]), address(transferator2));
        }
        assertEq(transferator2.totalERC721Migrated(address(this)), 2);
    }

 function test_WithdrawTokens() public {
   
    uint256 depositAmount = 1e18;
    token.approve(address(transferator2), depositAmount);
    transferator2.migrateTokens(depositAmount);

    uint256 contractTokenBalanceBefore = token.balanceOf(address(transferator2));
    uint256 receiverTokenBalanceBefore = token.balanceOf(receiver);

    transferator2.withdrawTokens();

    assertEq(token.balanceOf(address(transferator2)), 0);
    assertEq(token.balanceOf(receiver), receiverTokenBalanceBefore + contractTokenBalanceBefore);
}

 function test_WithdrawNFTs() public {
    
    uint256[] memory tokenIds = new uint256[](2);
    tokenIds[0] = 1;
    tokenIds[1] = 2;
   
     for (uint256 i = 0; i < tokenIds.length; i++) {
            nft.approve(address(transferator2), tokenIds[i]);
        }
      
   transferator2.migrateNFTs(tokenIds);

    for (uint256 i = 0; i < tokenIds.length; i++) {
        assertEq(nft.ownerOf(tokenIds[i]), receiver);
    }
}}






