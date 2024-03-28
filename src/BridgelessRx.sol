// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ed25519} from "./libraries/Ed25519.sol";

contract BridgelessRx{
    uint256 constant WINDOW_SIZE = 12; //Curently represented as hours
    uint256 constant WINDOW_DEPOSIT_LIMIT = 3 ether;

    uint256 totalAmount = 0;
    uint256 slidingWindowIndex = 0;
    Transaction[] transactions;

    uint256 public committeSize = 0;
    mapping(address => bool) sigCommittee;
    mapping(bytes => bytes[]) sigBuffer;
    mapping(bytes => mapping(address => bool)) sigState;

    event BridgelessTransfer(
        address to,
        uint256 amount
    );

    struct Transaction{
        uint256 timestamp;
        uint256 amount;
    }

    struct BridgelessTransaction{
        uint256 actionId;
        address to;
        uint256 amount;
    }

    function executeMessage(bytes memory sig, bytes memory txn) public {
        address signer = verifySig(sig);
        require(sigCommittee[signer], "BridgelessRx: signer not part of committee");
        require(!sigState[txn][signer], "BridgelessRx: signer has already been verified");
        sigBuffer[txn].push(sig);

        BridgelessTransaction[] memory txnHashes = abi.decode(txn, (BridgelessTransaction[]));

        if(sigBuffer[txn].length > committeSize/2){
            uint256 totalTransactionAmount = 0;
            updateSlidingWindow(block.timestamp - (WINDOW_SIZE * 3600));

            for(uint256 i = 0; i < txnHashes.length; i++){
                (, address to, uint256 amount) = (txnHashes[i].actionId, txnHashes[i].to, txnHashes[i].amount);

                totalTransactionAmount += amount;
                require(totalAmount + totalTransactionAmount <= WINDOW_DEPOSIT_LIMIT, "BridgelessRx: amount to be transferred exceeds sliding window transfer limit");           
                (bool success, ) = to.call{value: amount}("");
                require(success, "BridgelessRx: transfer failed");
                emit BridgelessTransfer(to, amount);
            }

            transactions.push(Transaction(block.timestamp, totalTransactionAmount));
            totalAmount += totalTransactionAmount;
        }
    } 

    function verifySig(/*bytes32 publicKey, bytes32 r, bytes32 s, bytes memory message*/ bytes memory sig) internal view returns(address){
        //require(Ed25519.verify(publicKey, r, s, message), "BridgelessRx: signature invalid");
        return msg.sender;
    }
    
    function updateSlidingWindow(uint256 _startTime) internal {
        while(slidingWindowIndex < transactions.length){
            if(transactions[slidingWindowIndex].timestamp < _startTime){
                totalAmount -= transactions[slidingWindowIndex].amount;
            } 
            else{
                break;
            }
            slidingWindowIndex++;
        }
    }

    // test function
    function updateCommittee(address member, bool state) external{
        sigCommittee[member] = state;
    }
}