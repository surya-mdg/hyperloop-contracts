// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgeRx} from "../src/BridgeRx.sol";
import {Ed25519} from "../lib/encryption/Ed25519.sol";

contract SourceTest is Test {
    BridgeRx public bridgeRx;
    uint256 public constant CONVERSION_DECIMALS = 1e18;
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    bytes32 public signer = vm.envBytes32("NODE1_PUBLIC_KEY");
    bytes[] public txns;

    function setUp() public{
        vm.startBroadcast();
        bridgeRx = new BridgeRx();
        vm.deal(address(bridgeRx), 5 ether);
        vm.deal(user1, 5 ether);
        vm.deal(user2, 5 ether);
        bridgeRx.updateCommittee(signer, true);
        vm.stopBroadcast();
    }

    function test_ExecuteMessageSuccess() public{
        vm.warp(2 days);
        vm.chainId(80002);
        vm.startPrank(user1);
        txns.push(abi.encode(BridgeRx.BridgeTransaction(1, user2, 80002, 1 ether, user1, 3 * 1e21, CONVERSION_DECIMALS, 4 days)));
        console.logBytes(abi.encode(txns));
        bytes memory sig = hex"E83BF9BAE3212CD80663182BBF045030E4B774846763C653F50BE22CCB2BE022F2ABC87805EDF8474A9734921DA688AE39C382A7E8EF72512C82B54C11956E06";

        console.log("Balance Before: %d", user2.balance);

        vm.expectEmit(true, true, true, false);
        emit BridgeRx.BridgeTransferCompleted(user2, 1 ether, block.timestamp);
        bridgeRx.executeMessage(signer, sig, abi.encode(txns));
        console.log("Balance After: %d", user2.balance);

    }

    function test_ExecuteMessageRevert() public{
        vm.warp(2 days);
        vm.chainId(80002);
        vm.startPrank(user1);
        txns.push(abi.encode(BridgeRx.BridgeTransaction(1, user2, 80002, 1 ether, user1, 3 * 1e21, CONVERSION_DECIMALS, 1 days))); // revertPeriod is of time past
        console.logBytes(abi.encode(txns));
        bytes memory sig = hex"E83BF9BAE3212CD80663182BBF045030E4B774846763C653F50BE22CCB2BE022F2ABC87805EDF8474A9734921DA688AE39C382A7E8EF72512C82B54C11956E06";

        console.log("Balance Before: %d", user2.balance);

        BridgeRx.RevertTransaction memory rTx = BridgeRx.RevertTransaction(1, user1, 1 ether);
        vm.expectEmit(true, true, false, false);
        emit BridgeRx.RevertedReq(1, rTx);
        bridgeRx.executeMessage(signer, sig, abi.encode(rTx));
        console.log("Balance After: %d", user2.balance);

    }

    // function test_Ed25519() pure public{
    //     bytes32 r;
    //     bytes32 s;
    //     bytes32 k = 0x06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435;
    //     bytes memory sig = hex"a6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b81160af2842235a0257fc1d3e968c2c1c9f56f117da3186effcaeda256c38a0d";
    //     bytes memory m = hex"b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc";
    //     assembly{
    //         r:= mload(add(sig,32))
    //         s:= mload(add(sig,64))
    //     }

    //     assertEq(Ed25519.verify(k,r,s,m), true);

    //     sig = hex"b6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b81160af2842235a0257fc1d3e968c2c1c9f56f117da3186effcaeda256c38a0d";
    //     assembly{
    //         r:= mload(add(sig,32))
    //         s:= mload(add(sig,64))
    //     }

    //     assertEq(Ed25519.verify(k,r,s,m), false);
    // }

    //0xa6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc
    //private key: B583220215144D856030DCA19F5F800B6908F1F3E0D9168E1D3FFA73017FB2CA
}
