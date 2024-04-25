// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract BridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bridgeTx = new BridgeTx();
        console.log("BridgeTx at : ", address(bridgeTx)); // 0x4a7d3d5691D88E8A4F56e36D364e0FFD8292E2ED
        vm.stopBroadcast();
    }
}
