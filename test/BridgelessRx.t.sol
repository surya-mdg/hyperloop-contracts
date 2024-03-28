// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgelessRx} from "../src/BridgelessRx.sol";
import {Ed25519} from "../src/libraries/Ed25519.sol";
import {ed25519} from "../src/libraries/ed25519-Rust.sol";
import {Sha512} from "../src/libraries/Sha512.sol";

contract SourceTest is Test {
    BridgelessRx public brx;
    ed25519 public ed;
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    BridgelessRx.BridgelessTransaction[] public txnHashes;

    function setUp() public{
        brx = new BridgelessRx();
        ed = new ed25519();
        vm.deal(address(brx), 5 ether);
        vm.deal(user1, 5 ether);
        vm.deal(user2, 5 ether);

        brx.updateCommittee(user1, true);
    }

    function test_ExecuteMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 1 ether));
        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 1000000 wei));

        console.log("Balance Before: %d", user2.balance);
        brx.executeMessage("aaa", abi.encode(txnHashes));
        console.log("Balance After: %d", user2.balance);
    }

    function test_ExecuteMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        
        txnHashes.push(BridgelessRx.BridgelessTransaction(1, user2, 4 ether));

        console.log("Balance Before: %d", user2.balance);
        vm.expectRevert("BridgelessRx: amount to be transferred exceeds sliding window transfer limit");
        brx.executeMessage("aaa", abi.encode(txnHashes));
        console.log("Balance After: %d", user2.balance);
    }

    function test_Ed25519() view public{
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
    }

    /*function test_ed25519() view public{
        bytes memory signature = hex"a6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b81160af2842235a0257fc1d3e968c2c1c9f56f117da3186effcaeda256c38a0d";
        bytes memory m = hex"b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc";
        uint256[2] memory publicKey;
        publicKey[0] = 10;
        publicKey[1] = 23;
        console.logBool(ed.verifySignature(m, signature, convertHexStringToUint256Array("06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435")));
    }*/

    function convertHexStringToUint256Array(string memory hexString) internal pure returns (uint256[2] memory result) {
        bytes memory hexBytes = bytes(hexString);
        require(hexBytes.length == 64, "Invalid hex string length");
        
        assembly {
            mstore(result,          mload(add(hexBytes, 32)))
            mstore(add(result, 32), mload(add(hexBytes, 64)))
        }
    }

    //0xa6161c95fd4e3237b7dd12cc3052aaa69382510ecb5b89c2fbeb8b6efb78266b06cf14cfae0ff9fe7fdf773202029a3e8976465c8919f4840d1c3c77c8162435b0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc40943e2c10f2ad4ee49ab0d8bdfd9f4d1023dae836b2e41da5019d20c60965dc
}
