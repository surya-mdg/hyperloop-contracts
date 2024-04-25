// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract BridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bridgeTx = new BridgeTx();
        console.log("BridgeTx at : ", address(bridgeTx)); // 0x73c4a8d2d6cd1b723e48d4d5e2cccd3e436667a6
        vm.stopBroadcast();
    }
}

// https://sepolia.etherscan.io/address/0x73c4a8d2d6cd1b723e48d4d5e2cccd3e436667a6
