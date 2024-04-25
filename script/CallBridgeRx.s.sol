// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeRx} from "../src/BridgeRx.sol";


contract CallBridgeRxScript is Script {
    BridgeRx public bridgeRx;
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bridgeRx = BridgeRx(0x7B0bfb954f7527eE17fE2E07749d0d4C60806c2F);
        
        callExecute();
    }
    function callExecute() public {

    }
}
