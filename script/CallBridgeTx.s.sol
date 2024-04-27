// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract CallBridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeTx = BridgeTx(0x23Dd1Aa37b5c81d64586c021330D61D3Ad55AaFB);
        callPostMessage();
    }
    function callPostMessage() public {
        BridgeTx.BridgeTransfer[] memory bridgeTransfer = new BridgeTx.BridgeTransfer[] (1);

        BridgeTx.BridgeTransfer memory transfer1;
        transfer1.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer1.foreignChainId = 80002;
        transfer1.amount = 0.0111 ether;
        bridgeTransfer[0] = transfer1;

        BridgeTx.BridgeTransfer memory transfer2;
        transfer2.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer2.foreignChainId = 80002;
        transfer2.amount = 0.0112 ether;
        bridgeTransfer[0] = transfer2;

        BridgeTx.BridgeTransfer memory transfer3;
        transfer2.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer2.foreignChainId = 80002;
        transfer2.amount = 0.0113 ether;
        bridgeTransfer[0] = transfer3;

        BridgeTx.BridgeTransfer memory transfer4;
        transfer2.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer2.foreignChainId = 80002;
        transfer2.amount = 0.0114 ether;
        bridgeTransfer[0] = transfer4;

        BridgeTx.BridgeTransfer memory transfer5;
        transfer2.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer2.foreignChainId = 80002;
        transfer2.amount = 0.0115 ether;
        bridgeTransfer[0] = transfer5;

        bridgeTx.postMessage{value: 0.06 ether}(bridgeTransfer);
    }
}
