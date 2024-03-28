// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Ed25519} from "../lib/encryption/Ed25519.sol";

contract BridgelessRx{
    uint256 public constant WINDOW_SIZE = 12; // Currently represented in hours
    uint256 public constant WINDOW_DEPOSIT_LIMIT = 3 ether;

    uint256 totalTxnAmount = 0;
    uint256 slidingWindowIndex = 0;
    Transaction[] completedTxns;

    uint256 public sigCommitteeSize = 0;
    mapping(bytes32 => bool) public sigCommittee;
    mapping(bytes => bytes[]) public sigBuffer; // Can use uint256 instead of bytes[] if signatures need not be stored
    mapping(bytes => mapping(bytes => bool)) public txnState; // To prevent duplicate signatures

    event BridgelessTransfer(
        address to,
        uint256 amount
    );

    struct BridgelessTransaction{
        uint256 actionId;
        address to;
        uint256 amount;
    }

    struct Transaction{
        uint256 timestamp;
        uint256 amount;
    }

    /*** 
     * @notice: Performs the completedTxns which have valid ed25519 signature
     * @param: signer - public key of the node that signed the completedTxns
     * @param: sig - ed25519 signature generated for the message
     * @param: txn - completedTxns for which the signature has been generated
    */
    function executeMessage(bytes32 signer, bytes memory sig, bytes memory txn) external {
        verifySig(signer, sig, txn);
        require(sigCommittee[signer], "BridgelessRx: signer not part of committee");
        require(!txnState[txn][sig], "BridgelessRx: signer has already been verified");
        sigBuffer[txn].push(sig);
        txnState[txn][sig] = true;

        BridgelessTransaction[] memory txnHashes = abi.decode(txn, (BridgelessTransaction[]));

        if(sigBuffer[txn].length > sigCommitteeSize / 2){
            uint256 totalTransactionAmount = 0;
            updateSlidingWindow(block.timestamp - (WINDOW_SIZE * 3600));

            for(uint256 i = 0; i < txnHashes.length; i++){
                (, address to, uint256 amount) = (txnHashes[i].actionId, txnHashes[i].to, txnHashes[i].amount);

                totalTransactionAmount += amount;
                require(totalTxnAmount + totalTransactionAmount <= WINDOW_DEPOSIT_LIMIT, "BridgelessRx: amount to be transferred exceeds sliding window transfer limit");           
                (bool success, ) = to.call{value: amount}("");
                require(success, "BridgelessRx: transfer failed");
                emit BridgelessTransfer(to, amount);
            }

            completedTxns.push(Transaction(block.timestamp, totalTransactionAmount));
            totalTxnAmount += totalTransactionAmount;
        }
    } 

    /*** 
     * @notice: Verifies the ed25519 signature
     * @param: publicKey - public key of the node that signed this message
     * @param: sig - ed25519 signature generated for the message
     * @param: message - message that has been signed using the node private key
    */
    function verifySig(bytes32 publicKey, bytes memory sig, bytes memory message) internal pure {
        bytes32 r;
        bytes32 s;
        assembly{
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
        }
        require(Ed25519.verify(publicKey, r, s, message), "BridgelessRx: signature invalid");
    }
    
    /*** 
     * @notice: Update the total transaction amount made within the slinding window duraction
     * @param: _startTime - current starting time of the slinding window 
    */
    function updateSlidingWindow(uint256 _startTime) internal {
        while(slidingWindowIndex < completedTxns.length){
            if(completedTxns[slidingWindowIndex].timestamp < _startTime){
                totalTxnAmount -= completedTxns[slidingWindowIndex].amount;
            } 
            else{
                break;
            }
            slidingWindowIndex++;
        }
    }

    // TEST Function
    /*** 
     * @notice: Updates the signature committee
     * @param: member - public key of node
     * @param: state - is node part of signature committee
    */
    function updateCommittee(bytes32 member, bool state) external{
        sigCommittee[member] = state;
    }
}