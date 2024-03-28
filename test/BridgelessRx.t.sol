// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgelessRx} from "../src/BridgelessRx.sol";
import {Ed25519} from "../lib/encryption/Ed25519.sol";

contract SourceTest is Test {
    BridgelessRx public brx;
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    bytes32 public signer = 0x292C70EBBBD20F278DB008B93A76D39AD5D87299883E59BC2CD5900F2EB849C2;
    BridgelessRx.BridgelessTransaction[] public txnHashes;

    function setUp() public{
        brx = new BridgelessRx();
        vm.deal(address(brx), 5 ether);
        vm.deal(user1, 5 ether);
        vm.deal(user2, 5 ether);

        brx.updateCommittee(signer, true);
    }

    function test_ExecuteMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        bytes memory sig = hex"CA69906813B443FAC1D047DA4E73472DA34B873D2B8C6698C185859F3DDB860C8C5E871FDA0510C9B37ADA883B85ED09B42A141817C4652B3AB4A67D2D8C1708";

        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 1 ether));
        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 1000000 wei));

        console.log("Balance Before: %d", user2.balance);
        brx.executeMessage(signer, sig, abi.encode(txnHashes));
        console.log("Balance After: %d", user2.balance);

        vm.expectRevert("BridgelessRx: signer has already been verified");
        brx.executeMessage(signer, sig, abi.encode(txnHashes));
    }

    function test_ExecuteMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        bytes memory sig = hex"CA71E244797ABC62B7CD44B1C8BBDAD6E53299E39BD2EC2190E6A0B565828739565C1D7E5B9DED744394AE43A5FAED8778EFA23B0F53BDFF0810BE0C98BE2100";
        
        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 4 ether));

        console.log("Balance Before: %d", user2.balance);
        vm.expectRevert("BridgelessRx: amount to be transferred exceeds sliding window transfer limit");
        brx.executeMessage(signer, sig, abi.encode(txnHashes));
        console.log("Balance After: %d", user2.balance);
    }

    function test_Ed25519() pure public{
        bytes32 r;
        bytes32 s;
        bytes32 k = 0x06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435;
        bytes memory sig = hex"a6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b81160af2842235a0257fc1d3e968c2c1c9f56f117da3186effcaeda256c38a0d";
        bytes memory m = hex"b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc";
        assembly{
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
        }

        assertEq(Ed25519.verify(k,r,s,m), true);

        sig = hex"b6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b81160af2842235a0257fc1d3e968c2c1c9f56f117da3186effcaeda256c38a0d";
        assembly{
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
        }

        assertEq(Ed25519.verify(k,r,s,m), false);
    }

    //0xa6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc
    //private key: B583220215144D856030DCA19F5F800B6908F1F3E0D9168E1D3FFA73017FB2CA
}
