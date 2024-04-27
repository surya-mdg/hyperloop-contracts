// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract CallBridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeTx = BridgeTx(0x371862509e523e8FB89EB8911254c14C882fcA96);
        callPostMessage();
    }
    function callPostMessage() public {
        BridgeTx.BridgeTransfer[] memory bridgeTransfer = new BridgeTx.BridgeTransfer[] (1);

        BridgeTx.BridgeTransfer memory transfer1;
        transfer1.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer1.foreignChainId = 80002;
        transfer1.amount = 0.011 ether;

        bridgeTransfer[0] = transfer1;
        bridgeTx.postMessage{value: 0.011 ether}(bridgeTransfer);
    }
}
