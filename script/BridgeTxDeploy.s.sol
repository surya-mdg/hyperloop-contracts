// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract BridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeTx = new BridgeTx();
        console.log("BridgeTx at : ", address(bridgeTx)); // 
        vm.stopBroadcast();
    }
}