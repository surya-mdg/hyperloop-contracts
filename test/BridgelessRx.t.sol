// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgelessRx} from "../src/BridgelessRx.sol";

contract SourceTest is Test {
    BridgelessRx public brx;
    address public user1 = vm.addr(1);
    address public user2 = vm.addr(2);
    bytes[] public sigs;
    bytes[] public txnHashes;

    function setUp() public{
        brx = new BridgelessRx();
        vm.deal(address(brx), 5 ether);
        vm.deal(user1, 5 ether);
        vm.deal(user2, 5 ether);

        brx.updateCommittee(user1, true);
    }

    function test_ExecuteMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        
        sigs.push("aaa");
        sigs.push("bbb");
        txnHashes.push(abi.encode(1, user2, 1 ether));
        txnHashes.push(abi.encode(1, user2, 1000000 wei));

        console.log("Balance Before: %d", user2.balance);
        brx.executeMessage(sigs, txnHashes);
        console.log("Balance After: %d", user2.balance);
    }

    function test_ExecuteMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        
        sigs.push("aaa");
        txnHashes.push(abi.encode(1, user2, 4 ether));

        console.log("Balance Before: %d", user2.balance);
        vm.expectRevert("BridgelessRx: amount to be transferred exceeds slinding window transfer limit");
        brx.executeMessage(sigs, txnHashes);
        console.log("Balance After: %d", user2.balance);
    }
}
