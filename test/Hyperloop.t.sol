// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol"; //@dev: Library

import {IHyperloop} from "../src/contracts/interfaces/IHyperloop.sol";
import {Implementation} from "../src/contracts/hyperloop-core/implementations/Implementation.sol";
import {Hyperloop} from "../src/contracts/hyperloop-core/Hyperloop.sol";
import {Governance} from "../src/contracts/governance/Governance.sol";

import {BridgeTx} from "../src/contracts/hyperloop-transfer/implementations/BridgeTx.sol";
import {BridgeRx} from "../src/contracts/hyperloop-transfer/implementations/BridgeRx.sol";

contract HypernovaNFTBridgeTest is Test{
    bytes32 public signer = 0x292C70EBBBD20F278DB008B93A76D39AD5D87299883E59BC2CD5900F2EB849C2;
    uint256 public DEPLOYER = 0x853024a95f52d73fe68a50e4ee1a83754a6818ef71b63eccea9c07edde5e595c;
    uint256 public BASE_CORE_FEE = 100 wei;
    uint16 public CHAIN_ID = 1;
    uint256 public FINALITY_FACTOR = 200;

    address public user1 = vm.addr(3);
    address public user2 = vm.addr(5);

    Implementation public implementation;
    Hyperloop public hyperloop;
    IHyperloop public hyperloopProxy;
    Governance public governance;

    //Transaction Code
    BridgeTx public btx;
    BridgeTx.BridgelessTransfer[] public messageArr;
    bytes32[] public sigCommittee;

    BridgeRx public brx;
    BridgeRx.BridgelessTransaction[] public txnHashes;

    function setUp() public{
        vm.chainId(CHAIN_ID);
        vm.startBroadcast(DEPLOYER);

        sigCommittee.push(signer);

        implementation = new Implementation();
        governance = new Governance();
        bytes memory initializationData = abi.encodeWithSelector(IHyperloop.initialize.selector,address(governance), BASE_CORE_FEE, CHAIN_ID, sigCommittee);
        hyperloop = new Hyperloop(address(implementation), initializationData);
        hyperloopProxy = IHyperloop(address(hyperloop));

        btx = new BridgeTx(address(hyperloopProxy));
        vm.deal(user1, 20 ether);

        brx = new BridgeRx(address(hyperloopProxy));
        vm.deal(address(brx), 5 ether);
        vm.deal(user2, 5 ether);

        vm.stopBroadcast();
    }

    function test_PostMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        BridgeTx.BridgelessTransfer memory message = BridgeTx.BridgelessTransfer("0x000d", 1, 1 ether);     
        messageArr.push(message);

        btx.postMessage{value: 1 ether + BASE_CORE_FEE}(messageArr);
    }

    function test_PostMessageFail() public{
        vm.warp(2 days);
        vm.startPrank(user1);

        BridgeTx.BridgelessTransfer memory message = BridgeTx.BridgelessTransfer("0x000d", 1, 4 ether);     
        messageArr.push(message);

        vm.expectRevert("BridgelessTx: amount to be transferred exceeds slinding window transfer limit");
        btx.postMessage{value: 1 ether + BASE_CORE_FEE}(messageArr);
    }

    function test_ExecuteMessageSuccess() public{
        vm.warp(2 days);
        vm.startPrank(user1);
        bytes memory sig = hex"4FC4D6A030795069CDDE3CC2B88FF70070BCC0F3626B60BC719137A4C6FCEB0F1454BD753AE07DC0803FFE817CDF656D5758E6432AC1270D4D3DB709B9919A00";

        txnHashes.push(BridgeRx.BridgelessTransaction(1, user2, 1 ether));
        txnHashes.push(BridgeRx.BridgelessTransaction(1, user2, 1000000 wei));

        console.logBytes(abi.encode(txnHashes));

        console.log("Balance Before: %d", user2.balance);
        brx.executeMessage(signer, sig, abi.encode(txnHashes));
        console.log("Balance After: %d", user2.balance);

        vm.expectRevert("BridgelessRx: signer has already been verified");
        brx.executeMessage(signer, sig, abi.encode(txnHashes));

        // abi.encode(txnHashes): 000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001000000000000000000000000e1ab8145f7e55dc933d51a18c793f901a3a0b2760000000000000000000000000000000000000000000000000de0b6b3a76400000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000e1ab8145f7e55dc933d51a18c793f901a3a0b27600000000000000000000000000000000000000000000000000000000000f4240
    }
}