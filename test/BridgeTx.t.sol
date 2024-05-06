// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {BridgeTx} from "../src/BridgeTx.sol";

contract SourceTest is Test {
    BridgeTx public btx;
    address public user1 = vm.addr(1);
    BridgeTx.BridgeTransfer[] public messageArr;

    event BridgeTransaction(
        uint256 indexed globalActionId,
        address indexed foreignAddress,
        uint256 indexed amount,
        uint256 timestamp,
        address from,
        uint256 foreignChainId,
        uint256 conversionRate,
        uint256 conversionDecimals
    );

    function setUp() public{
        btx = new BridgeTx();
        vm.deal(user1, 20 ether);
    }

    function test_PostMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        uint256 _chainId = 0;
        uint256 _actionId = uint256(keccak256(abi.encodePacked(_chainId, block.chainid, address(btx), block.timestamp)));
        BridgeTx.BridgeTransfer memory message = BridgeTx.BridgeTransfer(address(0x000d), 1, 1 ether);
        messageArr.push(message);

        BridgeTx.BridgeTransfer memory message2 = BridgeTx.BridgeTransfer(address(0x000d), 1, 0.2 ether);
        messageArr.push(message2);

        vm.expectEmit(true, true, true, true);
        emit BridgeTransaction(_actionId, address(0x000d), 1 ether, block.timestamp, user1,  1, 3 * 1e21, 1e18);
        vm.expectEmit(false, false, false, true);
        emit BridgeTransaction(_actionId, address(0x000d), 0.2 ether, block.timestamp, user1,  1, 3 * 1e21, 1e18);
        btx.postMessage{value: 1.2 ether}(messageArr);
    }

    function test_PostMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        BridgeTx.BridgeTransfer memory message = BridgeTx.BridgeTransfer(address(0x000d), 1, 4 ether);     
        messageArr.push(message);

        vm.expectRevert("BridgeTx: amount to be transferred exceeds slinding window transfer limit");
        btx.postMessage{value: 1 ether}(messageArr);
    }
}
