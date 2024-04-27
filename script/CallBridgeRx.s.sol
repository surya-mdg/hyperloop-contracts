// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {BridgeRx} from "../src/BridgeRx.sol";
import {BridgeTx} from "../src/BridgeTx.sol";



contract CallBridgeRxScript is Script {
    BridgeRx public bridgeRx;
    function run() public {
        vm.startBroadcast(vm.envUint("DEPLOYER_PRIVATE_KEY"));
        bridgeRx = BridgeRx(payable(0xE240cCa0469ee7bA9F49C460BCb3AE2b3Dd7d70B));
        // callUpdateCommittee(true, true, true, true, true);
        // callWithdraw();
        vm.stopBroadcast();
    }
    function callUpdateCommittee(bool n1, bool n2, bool n3, bool n4, bool n5) public {

        bytes32 node1 = vm.envBytes32("NODE1_PUBLIC_KEY");
        bytes32 node2 = vm.envBytes32("NODE2_PUBLIC_KEY");
        bytes32 node3 = vm.envBytes32("NODE3_PUBLIC_KEY");
        bytes32 node4 = vm.envBytes32("NODE4_PUBLIC_KEY");
        bytes32 node5 = vm.envBytes32("NODE5_PUBLIC_KEY");

        bridgeRx.updateCommittee(node1, n1);
        bridgeRx.updateCommittee(node2, n2);
        bridgeRx.updateCommittee(node3, n3);
        bridgeRx.updateCommittee(node4, n4);
        bridgeRx.updateCommittee(node5, n5);

    }

    function simulateNode() public {
        bytes32 signer1 = 0x15FD1BF7A7F223445355C4840B5F9ABD07BFCDE68548BFA03F4F603627076195;
        bytes memory sig =  hex"ECC607B759B04CAA82B6D585534C9D3CB6C939443B6BEF498A7E8313333786086D251CA048BC96274D3B1430067CF52834C98856493920ADF6D8E23DBD94C40E";
        
        BridgeTx.BridgeTransfer[] memory bridgeTransfer = new BridgeTx.BridgeTransfer[] (1);
        BridgeTx.BridgeTransfer memory transfer1;
        transfer1.foreignAddress = address(0x699BceEbD59a5b52bB586C737cD7ba636f3Fe602); // Account on Polygon Amoy
        transfer1.foreignChainId = 80002;
        transfer1.amount = 0.11 ether;
        bridgeTransfer[0] = transfer1;

        bytes memory txns = hex"00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000601ca1ecb509521825e5420c69091debb2205537cfc00542447ff7a4e341cfdc82000000000000000000000000699bceebd59a5b52bb586c737cd7ba636f3fe602000000000000000000000000000000000000000000000000002386f26fc10000";
        
        bridgeRx.executeMessage(signer1, sig, txns);
    }

    function callWithdraw() public{
        bridgeRx.withdrawFunds(0.399 ether);
    }
}
