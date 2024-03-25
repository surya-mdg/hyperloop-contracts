// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

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

    function executeMessage(bytes[] memory sigs, bytes[] memory txnHashes) external {
        uint256 totalTransactionAmount = 0;
        for(uint256 i = 0; i < txnHashes.length; i++){
            (, address to, uint256 amount) = abi.decode(txnHashes[i], (uint256, address, uint256));

            address signer = verifySig(sigs[i]);
            require(sigCommittee[signer], "BridgelessRx: signer not part of committee");
            require(!sigState[txnHashes[i]][signer], "BridgelessRx: signer has already been verified");

            sigBuffer[txnHashes[i]].push(sigs[i]);
            if(sigBuffer[txnHashes[i]].length > committeSize/2){
                updateSlidingWindow(block.timestamp - (WINDOW_SIZE * 3600));
                totalTransactionAmount += amount;
                require(totalAmount + totalTransactionAmount <= WINDOW_DEPOSIT_LIMIT, "BridgelessRx: amount to be transferred exceeds slinding window transfer limit");           

                (bool success, ) = to.call{value: amount}("");
                require(success, "BridgelessRx: transfer failed");
                emit BridgelessTransfer(to, amount);
            }
        }

        transactions.push(Transaction(block.timestamp, totalTransactionAmount));
        totalAmount += totalTransactionAmount;
    } 

    function verifySig(bytes memory _sig) internal view returns(address){
        // ec25519 logic
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