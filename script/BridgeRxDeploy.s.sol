// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeRx} from "../src/BridgeRx.sol";


contract BridgeRxScript is Script {
    BridgeRx public bridgeRx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeRx = new BridgeRx();
        console.log("BridgeRx at : ", address(bridgeRx)); // 0x7B0bfb954f7527eE17fE2E07749d0d4C60806c2F
        vm.stopBroadcast();
    }
}
