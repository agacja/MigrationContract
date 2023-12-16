//   _    _       _       _         __  __ _                 _   _             
//  | |  | |     (_)     | |       |  \/  (_)               | | (_)            
//  | |  | |_ __  _  __ _| |_   _  | \  / |_  __ _ _ __ __ _| |_ _  ___  _ __  
//  | |  | | '_ \| |/ _` | | | | | | |\/| | |/ _` | '__/ _` | __| |/ _ \| '_ \ 
//  | |__| | | | | | (_| | | |_| | | |  | | | (_| | | | (_| | |_| | (_) | | | |
//   \____/|_| |_|_|\__, |_|\__, | |_|  |_|_|\__, |_|  \__,_|\__|_|\___/|_| |_|
//                     | |   __/ |            __/ |                            
//                     |_|  |___/            |___/                             

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
error MigrationClosed();

/**
 * @title  UniqlyMigration
 * @notice Optimised Migration contract of ERC20, ERC721
 * @author Agacja (@Agacja2)
 * @author Uniqly (@Uniqly_io)
 */

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "solmate/auth/Owned.sol";
import "solady/src/utils/SafeTransferLib.sol";

contract UniqlyMigration is Owned(msg.sender), ERC721Holder {
    uint8 public saleState; // 0 - closed, 1 - open
    address public uniqToken; // Uniqly token address
    address public nft; // Genesis NFT address
    address receiver = 0x1e526ecc6CDcaB653823968b58056Ad5b438C92b;

    // Mappings to record the quantities involved in the claim application process, required for the Dapp.
    mapping(address => uint256) public totalERC20Migrated;
    mapping(address => uint256) public totalERC721Migrated;

    constructor(address _uniqToken, address _nft) {
        uniqToken = _uniqToken;
        nft = _nft;
    }

    using SafeERC20 for IERC20;

    // Function to migrate ERC20 tokens.
    function migrateTokens(uint256 amount) external {
        if (saleState != 1) {
            revert MigrationClosed();
        }
        address vault = address(this);

        assembly {
            // Load caller address and totalERC20Migrated storage slot into memory.
            mstore(0x0, caller())
            mstore(0x20, totalERC20Migrated.slot)

            // Compute storage location and load the current total migrated amount.
            let location := keccak256(0x0, 0x40)
            let currentTotal := sload(location)
            let newTotal := add(currentTotal, amount)

            // Check for overflow and update the total migrated amount.
            if lt(newTotal, currentTotal) {
                mstore(0x00, 0x01336cea) // Custom error identifier.
                revert(0x1c, 0x04)
            }
            sstore(location, newTotal)

            // Load the ERC20 token address from storage.
            let tok := sload(uniqToken.slot)

            // Prepare ERC20 token transfer call.
            mstore(0x00, hex"23b872dd") // ERC20 transferFrom function signature.
            mstore(0x04, caller()) // From address (caller).
            mstore(0x24, vault) // To address (contract itself).
            mstore(0x44, amount) // Amount to transfer.

            // Execute the transfer and revert on failure.
            if iszero(call(gas(), tok, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }
        }
    }

    // Function to migrate ERC721 tokens (NFTs).
    function migrateNFTs(uint256[] calldata tokenIds) external {
        if (saleState != 1) {
            revert MigrationClosed();
        }
        address vault = address(this);

        assembly {
            // Load caller address and totalERC721Migrated storage slot into memory.
            mstore(0x0, caller())
            mstore(0x20, totalERC721Migrated.slot)
            let location := keccak256(0x0, 0x40)

            // Load the current total migrated count.
            let currentTotal := sload(location)

            // Calculate the length of tokenIds array.
            let length := calldataload(sub(tokenIds.offset, 0x20))
            let dataStart := add(tokenIds.offset, 0x20)
            let n := calldatasize()

            // Iterate over each tokenId and transfer it.
            for {
                let i := tokenIds.offset
            } lt(i, n) {
                i := add(i, 0x20)
            } {
                let tokenId := calldataload(i)
                let uni := sload(nft.slot)

                // Prepare ERC721 token transfer call.
                mstore(0x00, hex"23b872dd") // ERC721 transferFrom function signature.
                mstore(0x04, caller()) // From address (caller).
                mstore(0x24, vault) // To address (contract itself).
                mstore(0x44, tokenId) // TokenId to transfer.

                // Execute the transfer and revert on failure.
                if iszero(call(gas(), uni, 0, 0x00, 0x64, 0, 0)) {
                    revert(0, 0)
                }

                // Increment the total migrated count.
                currentTotal := add(currentTotal, 1)
            }

            // Check for underflow/overflow and update the total migrated count.
            if or(
                lt(currentTotal, length),
                iszero(gt(currentTotal, sload(location)))
            ) {
                mstore(0x00, 0x01336cea) // Custom error identifier.
                revert(0x1c, 0x04)
            }
            sstore(location, currentTotal)
        }
    }

    // Function to set the sale state.
    function setSaleState(uint8 value) external onlyOwner {
        require(value == 0 || value == 1, "Invalid state value");
        saleState = value;
    }

    // Function to withdraw both Ethereum and ERC20 tokens from the contract.
    function withdrawTokens() external payable onlyOwner {
        uint256 _uniqBalance = IERC20(uniqToken).balanceOf(address(this));
        SafeTransferLib.safeApprove(uniqToken, receiver, type(uint256).max);
        SafeTransferLib.safeTransfer(uniqToken, receiver, _uniqBalance);
    }

    // Function to withdraw ERC721 tokens (NFTs) from the contract.
    function withdrawNFTs(uint256[] calldata tokenIds) external onlyOwner {
        uint256 len = tokenIds.length; // cache >:D
        for (uint256 i = 0; i < len; i++) {
            IERC721(nft).safeTransferFrom(address(this), receiver, tokenIds[i]);
        }
    }
}
