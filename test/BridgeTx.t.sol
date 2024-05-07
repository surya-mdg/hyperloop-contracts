// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgeTx} from "../src/BridgeTx.sol";

contract SourceTest is Test {
    BridgeTx public bridgeTx;
    address public user1 = vm.addr(1);
    uint256 public constant CONVERSION_DECIMALS = 1e18;
    BridgeTx.BridgeTransfer[] public messageArr;

    event BridgeTxReq(
        uint256 indexed actionId, // could be globalActionId - if batchedEmit is false // globalBatchActionId - if batchedEmit is true
        address indexed from, // emitter
        uint256 indexed timestamp, // emitted time
        bytes[] txBridgeTransactionBytes // array of abi.encode(BridgeTransaction Struct)
    );

    function setUp() public{
        bridgeTx = new BridgeTx();
        vm.deal(user1, 20 ether);
    }

    function test_PostMessageSuccess() public{
        vm.warp(2 days);
        vm.chainId(1);
        vm.startPrank(user1);  
        bytes[] memory txBridgeTransactionBytes = new bytes[](2);

        uint256 chainId = 80002;
        uint256 actionId = 1;
        BridgeTx.BridgeTransaction memory btx1;
        btx1.actionId = actionId;
        btx1.foreignAddress = address(0x000d);
        btx1.foreignChainId = chainId;
        btx1.amount = 1 ether;
        btx1.from = user1;
        btx1.conversionRate = 3 * 1e21;
        btx1.conversionDecimals = CONVERSION_DECIMALS;
        btx1.revertPeriod = 1 days;
        txBridgeTransactionBytes[0] = abi.encode(btx1);

        BridgeTx.BridgeTransfer memory message1 = BridgeTx.BridgeTransfer(address(0x000d), chainId, 1 ether, 1 days);
        messageArr.push(message1);

        uint256 chainId2 = 80002;
        uint256 actionId2 = 2;
        BridgeTx.BridgeTransaction memory btx2;
        btx2.actionId = actionId2;
        btx2.foreignAddress = address(0x000d);
        btx2.foreignChainId = chainId2;
        btx2.amount = 2 ether;
        btx2.from = user1;
        btx2.conversionRate = 3 * 1e21;
        btx2.conversionDecimals = CONVERSION_DECIMALS;
        btx2.revertPeriod = 2 days;
        
        txBridgeTransactionBytes[1] = abi.encode(btx2);

        BridgeTx.BridgeTransfer memory message2 = BridgeTx.BridgeTransfer(address(0x000d), chainId2, 2 ether, 2 days);
        messageArr.push(message2);
        uint256 batchId = 1; // since it is batched emit
        vm.expectEmit(true, true, true, true);
        emit BridgeTxReq(batchId, user1, block.timestamp, txBridgeTransactionBytes);
        bridgeTx.postMessage{value: 3 ether}(messageArr);
    }

    // function test_PostMessageFail() public{
    //     vm.warp(2 days);
    //     vm.startPrank(user1);

    //     BridgeTx.BridgeTransfer memory message = BridgeTx.BridgeTransfer(address(0x000d), 1, 4 ether);     
    //     messageArr.push(message);

    //     vm.expectRevert("BridgeTx: amount to be transferred exceeds slinding window transfer limit");
    //     btx.postMessage{value: 1 ether}(messageArr);
    // }
}
