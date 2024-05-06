// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeTx} from "../src/BridgeTx.sol";


contract CallBridgeTxScript is Script {
    BridgeTx public bridgeTx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeTx = BridgeTx(0x23Dd1Aa37b5c81d64586c021330D61D3Ad55AaFB);
        // callPostMessage();
    }
    function callPostMessage() public {
        BridgeTx.BridgeTransfer[] memory bridgeTransfer = new BridgeTx.BridgeTransfer[] (20);

        {
        BridgeTx.BridgeTransfer memory transfer1;
        transfer1.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer1.foreignChainId = 80002;
        transfer1.amount = 0.0111 ether;
        bridgeTransfer[0] = transfer1;
        
        BridgeTx.BridgeTransfer memory transfer2;
        transfer2.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer2.foreignChainId = 80002;
        transfer2.amount = 0.0112 ether;
        bridgeTransfer[1] = transfer2;
      
        BridgeTx.BridgeTransfer memory transfer3;
        transfer3.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer3.foreignChainId = 80002;
        transfer3.amount = 0.0113 ether;
        bridgeTransfer[2] = transfer3;
       
        BridgeTx.BridgeTransfer memory transfer4;
        transfer4.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer4.foreignChainId = 80002;
        transfer4.amount = 0.0114 ether;
        bridgeTransfer[3] = transfer4;
        
        BridgeTx.BridgeTransfer memory transfer5;
        transfer5.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer5.foreignChainId = 80002;
        transfer5.amount = 0.0115 ether;
        bridgeTransfer[4] = transfer5;
        }

        {
        BridgeTx.BridgeTransfer memory transfer6;
        transfer6.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer6.foreignChainId = 80002;
        transfer6.amount = 0.0116 ether;
        bridgeTransfer[5] = transfer6;

        BridgeTx.BridgeTransfer memory transfer7;
        transfer7.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer7.foreignChainId = 80002;
        transfer7.amount = 0.0117 ether;
        bridgeTransfer[6] = transfer7;
        
        BridgeTx.BridgeTransfer memory transfer8;
        transfer8.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer8.foreignChainId = 80002;
        transfer8.amount = 0.0118 ether;
        bridgeTransfer[7] = transfer8;

        BridgeTx.BridgeTransfer memory transfer9;
        transfer9.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer9.foreignChainId = 80002;
        transfer9.amount = 0.0119 ether;
        bridgeTransfer[8] = transfer9;

        BridgeTx.BridgeTransfer memory transfer10;
        transfer10.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer10.foreignChainId = 80002;
        transfer10.amount = 0.0120 ether;
        bridgeTransfer[9] = transfer10;
        }

        {
        BridgeTx.BridgeTransfer memory transfer11;
        transfer11.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer11.foreignChainId = 80002;
        transfer11.amount = 0.0121 ether;
        bridgeTransfer[10] = transfer11;

        BridgeTx.BridgeTransfer memory transfer12;
        transfer12.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer12.foreignChainId = 80002;
        transfer12.amount = 0.0122 ether;
        bridgeTransfer[11] = transfer12;

        BridgeTx.BridgeTransfer memory transfer13;
        transfer13.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer13.foreignChainId = 80002;
        transfer13.amount = 0.0123 ether;
        bridgeTransfer[12] = transfer13;

        BridgeTx.BridgeTransfer memory transfer14;
        transfer14.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer14.foreignChainId = 80002;
        transfer14.amount = 0.0124 ether;
        bridgeTransfer[13] = transfer14;

        BridgeTx.BridgeTransfer memory transfer15;
        transfer15.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer15.foreignChainId = 80002;
        transfer15.amount = 0.0125 ether;
        bridgeTransfer[14] = transfer15;
        }
        {
        BridgeTx.BridgeTransfer memory transfer16;
        transfer16.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer16.foreignChainId = 80002;
        transfer16.amount = 0.0126 ether;
        bridgeTransfer[15] = transfer16;

        BridgeTx.BridgeTransfer memory transfer17;
        transfer17.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer17.foreignChainId = 80002;
        transfer17.amount = 0.0127 ether;
        bridgeTransfer[16] = transfer17;

        BridgeTx.BridgeTransfer memory transfer18;
        transfer18.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer18.foreignChainId = 80002;
        transfer18.amount = 0.0128 ether;
        bridgeTransfer[17] = transfer18;

        BridgeTx.BridgeTransfer memory transfer19;
        transfer19.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer19.foreignChainId = 80002;
        transfer19.amount = 0.0129 ether;
        bridgeTransfer[18] = transfer19;

        BridgeTx.BridgeTransfer memory transfer20;
        transfer20.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer20.foreignChainId = 80002;
        transfer20.amount = 0.0130 ether;
        bridgeTransfer[19] = transfer20;
        }
        bridgeTx.postMessage{value: 0.26 ether}(bridgeTransfer); //0.06 , 0.15, 0.2, 0.26
    }
}


