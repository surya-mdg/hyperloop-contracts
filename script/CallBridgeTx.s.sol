// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract CallBridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        bridgeTx = BridgeTx(0x4a7d3d5691D88E8A4F56e36D364e0FFD8292E2ED);
        callPostMessage();
    }
    function callPostMessage() public {
        BridgeTx.BridgeTransfer[] memory bridgeTransfer = new BridgeTx.BridgeTransfer[] (1);

        BridgeTx.BridgeTransfer memory transfer1;
        transfer1.foreignAddress = address(0x9b6137E8C04774F04fBd84d8f7302B7c384A109A); // Account 2
        transfer1.foreignChainId = 80002;
        transfer1.amount = 0.1 ether;

        bridgeTransfer[0] = transfer1;
        bridgeTx.postMessage{value: 0.1 ether}(bridgeTransfer);
    }
}
