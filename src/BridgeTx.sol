// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Ed25519} from "../lib/encryption/Ed25519.sol";

contract BridgeTx{
    uint256 public constant WINDOW_SIZE = 12; //Curently represented as hours
    uint256 public constant WINDOW_DEPOSIT_LIMIT = 10 ether;
    uint256 public constant CONVERSION_DECIMALS = 1e18;

    uint256 public actionId;
    uint256 public batchActionId;
    uint256 public revertedAmoutTillNow;

    address public owner;
    uint256 chainActionId = 0;
    uint256 totalAmount = 0;
    uint256 slidingWindowIndex = 0;
    Transaction[] transactions;
    mapping(uint256 => uint256) public conversionRates;

    uint256 public sigCommitteeSize = 0;
    mapping(bytes32 => bool) public sigCommittee;
    mapping(bytes => bytes[]) public sigBuffer; // Can use uint256 instead of bytes[] if signatures need not be stored
    mapping(bytes => mapping(bytes => bool)) public txnState; // To prevent duplicate signatures
    mapping(bytes txn => bool completed) public completedBridgeReq; 

    event BridgeTxReq(
        uint256 indexed actionId, // could be globalActionId - if batchedEmit is false // globalBatchActionId - if batchedEmit is true
        address indexed from, // emitter
        uint256 indexed timestamp, // emitted time
        bytes[] txBridgeTransactionBytes // array of abi.encode(BridgeTransaction Struct)
    );

    event RevertedReq(
        uint256 indexed globalActionId,
        address indexed from,
        uint256 indexed amount,
        int256 timePassed
    );

    event RevertCompleted(
        uint256 actionId,
        address from,
        uint256 amount
    );

    // Emitting as txBridgeTransactionBytes. Passing to relay node 
    struct BridgeTransaction{
        uint256 actionId;
        address foreignAddress;
        uint256 foreignChainId;
        uint256 amount;
        address from; // Duplicate but required for reverting
        uint256 conversionRate;
        uint256 conversionDecimals;
        uint256 revertPeriod; // future timestamp 
    }

    struct RevertTransaction{
        uint256 actionId;
        address from;
        uint256 amount;
        int256 timePassed;
    }

    // @notice: Passed by user to the postMessage()
    struct BridgeTransfer {
        address foreignAddress;
        uint256 foreignChainId;
        uint256 amount;
        uint256 revertPeriod;
    }

    struct Transaction{
        uint256 timestamp;
        uint256 amount;
    }

    constructor() {
        // Currently random value
        owner = msg.sender;
        conversionRates[1] = 3 * 1e21;
        conversionRates[80002] = 3 * 1e21; // Amoy
    }

    /*** 
     * @notice: Generates unique action ID
     * @return: unique action ID
    */
    function nextGlobalActionId() private returns (uint256) { 
        // return uint256(keccak256(abi.encodePacked(chainActionId++, block.chainid, address(this), block.timestamp)));
        actionId = actionId + 1;
        return actionId;
    }

    function nextGlobalBatchActionId() private returns (uint256){
        batchActionId = batchActionId + 1;
        return batchActionId;
    }

    /*** 
     * @notice: Check if transaction/batch of transactions don't violate sliding window limit & emit transactions
     * @param: txns - transactions to be made
    */
    function postMessage(BridgeTransfer[] memory txns) external payable returns(uint256){
        require(msg.value > 0, "BridgeTx: msg.value needs to be greater than 0");
        updateSlidingWindow(block.timestamp - (WINDOW_SIZE * 3600));

        uint256 totalTransactionAmount = 0;
        
        uint256 _actionId; // If txns.length == 1 only updates once

        bytes[] memory txBridgeTransactionBytes = new bytes[](txns.length);
        for (uint256 i = 0; i < txns.length; i++) {
            BridgeTransfer memory txn = txns[i];
            require(conversionRates[txn.foreignChainId] > 0, "BridgeTx: unsupported foreignChainId");
            totalTransactionAmount += txn.amount;
            require(totalAmount + totalTransactionAmount <= WINDOW_DEPOSIT_LIMIT, "BridgeTx: amount to be transferred exceeds slinding window transfer limit");

            BridgeTransaction memory btx;
            _actionId = nextGlobalActionId();
            btx.actionId = _actionId;
            btx.foreignAddress = txn.foreignAddress;
            btx.foreignChainId = txn.foreignChainId;
            btx.amount = txn.amount;
            btx.from = msg.sender;
            btx.conversionRate = conversionRates[txn.foreignChainId];
            btx.conversionDecimals = CONVERSION_DECIMALS;
            btx.revertPeriod = txn.revertPeriod;

            txBridgeTransactionBytes[i] = abi.encode(btx);
        }
        require(msg.value >= totalTransactionAmount, "BridgeTx: total transaction amount does not match msg.value");
        transactions.push(Transaction(block.timestamp, totalTransactionAmount));
        totalAmount += totalTransactionAmount;

        if (txns.length == 1){
            emit BridgeTxReq(
                _actionId,
                msg.sender,
                block.timestamp,
                txBridgeTransactionBytes
            );
            return _actionId;
        }

        uint256 _batchActionId = nextGlobalBatchActionId();
        emit BridgeTxReq(
            _batchActionId,
            msg.sender,
            block.timestamp,
            txBridgeTransactionBytes
        );
        return _batchActionId;

        
    }

    function revertTransaction(bytes32 signer, bytes memory sig, bytes memory txn) public{
        verifySig(signer, sig, txn);
        require(sigCommittee[signer], "BridgeRx: signer not part of committee");    
        require(!txnState[txn][sig], "BridgeRx: transaction has already been verified");      
        sigBuffer[txn].push(sig);
        txnState[txn][sig] = true;
        if (completedBridgeReq[txn]) {
            return;
        }

        if(sigBuffer[txn].length > sigCommitteeSize / 2){
            RevertTransaction memory rtx = abi.decode(txn, (RevertTransaction));
            (uint256 _actionId, address _from, uint256 _amount) = (rtx.actionId, rtx.from, rtx.amount);
            
            (bool success, ) = _from.call{value: _amount}("");
            require(success, "BridgeTx: revert transfer failed");
            emit RevertCompleted(_actionId, _from, _amount);
            completedBridgeReq[txn] = true;
        }
    }

    /*** 
     * @notice: Update the total transaction amount made within the slinding window duraction
     * @param: _startTime - current starting time of the slinding window 
    */
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

    // // --------------------- REVERT LOGIC ------------------------

    // /*** 
    //  * @notice: Performs the revert txns which have valid ed25519 signature
    //  * @param: signer - public key of the node that signed the completedTxns
    //  * @param: sig - ed25519 signature generated for the message
    //  * @param: txn - revert txn message for which the signature has been generated
    // */
    // function executeMessage(bytes32 signer, bytes memory sig, bytes memory txn) external {
    //     verifySig(signer, sig, txn);
    //     require(sigCommittee[signer], "BridgeTx: signer not part of committee");    
    //     require(!txnState[txn][sig], "BridgeTx: transaction has already been verified");      
    //     sigBuffer[txn].push(sig);
    //     txnState[txn][sig] = true;

    //     bytes[] memory txnHashes = abi.decode(txn, (bytes[]));

    //     if(sigBuffer[txn].length > sigCommitteeSize / 2){
    //         for(uint256 i = 0; i < txnHashes.length; i++){
    //             RevertTransfer memory _txn = abi.decode(txnHashes[i], (RevertTransfer));
    //             (uint256 actionId, address to, uint256 amount) = (_txn.actionId, _txn.to, _txn.amount);
       
    //             (bool success, ) = to.call{value: amount}("");
    //             require(success, "BridgeTx: revert transfer failed");
    //             emit RevertTransaction(actionId, to, amount);
    //         }   
    //     }
    // } 


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
        require(Ed25519.verify(publicKey, r, s, message), "BridgeTx: signature invalid");
    }

    /*** 
     * @notice: Updates the signature committee
     * @param: member - public key of node
     * @param: state - is node part of signature committee
    */
    function updateCommittee(bytes32 member, bool state) external{
        if(state){
            require(!sigCommittee[member], "BridgeTx: member already exists");
            sigCommitteeSize++;
        }
        else{
            require(sigCommittee[member], "BridgeTx: member does not exist");
            sigCommitteeSize--;
        }

        sigCommittee[member] = state;
    }
    
    function withdrawFunds(uint256 amount) public {
        require(msg.sender == owner, "BridgeTx: Not owner");
        require(address(this).balance >= amount, "BridgeTx: Insufficient funds");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Withdraw Failed");
    }
}