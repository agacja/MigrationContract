// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error SaleClosed();
error dupa();
error InsufficientAllowance();
import "lib/openzeppelin-contracts//contracts/token/ERC721/utils/ERC721Holder.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/solady/src/utils/ECDSA.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Transferator is Ownable, ERC721Holder{

    uint8 public saleState;
    IERC20 public token;
    address public signer;
    

    using ECDSA for bytes32;
    using SafeERC20 for IERC20;


 function transferNFT(uint256 amount,uint256 tokenIds, address _nft,

        bytes calldata signature
    ) external payable requireSignature(signature) {
    address voult =  address(this);
    address user = msg.sender;
   if (saleState != 1) {
        revert dupa();
        
   }
    if (token.allowance(msg.sender, address(this)) < amount) {
        revert dupa();
    }
     assembly{
            mstore(0x00, hex"23b872dd")
            mstore(0x04, user)
            mstore(0x24, voult)
            mstore(0x44, amount)

            
            if iszero(call(gas(), token.slot, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }

        mstore(0x00, hex"23b872dd") 
        mstore(0x04, caller())
        mstore(0x24, voult)
        mstore(0x44, tokenIds)

        if iszero(call(gas(), _nft, 0, 0x00, 0x64, 0, 0)) {
            revert(0, 0)
        }
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

}