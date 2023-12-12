// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {Wersja2} from "../src/Wersja2.sol";
import "forge-std/console.sol";
contract Wersja2Script is Script {
    function setUp() public {}

    function run() public {


        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address account = vm.addr(deployerPrivateKey);

        console.log("Account", account);



        vm.startBroadcast(deployerPrivateKey);
       
        vm.stopBroadcast();
    }
}
