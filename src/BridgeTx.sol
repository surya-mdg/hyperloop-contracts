// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

contract BridgeTx{
    uint256 public constant WINDOW_SIZE = 12; //Curently represented as hours
    uint256 public constant WINDOW_DEPOSIT_LIMIT = 10 ether;
    uint256 public constant CONVERSION_DECIMALS = 1e18;

    address public owner;
    uint256 chainActionId = 0;
    uint256 totalAmount = 0;
    uint256 slidingWindowIndex = 0;
    Transaction[] transactions;
    mapping(uint256 => uint256) public conversionRates;

    uint256 public sigCommitteeSize = 0;
    mapping(bytes32 => bool) public sigCommittee;

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

    struct BridgeTransfer {
        address foreignAddress;
        uint256 foreignChainId;
        uint256 amount;
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
        return uint256(keccak256(abi.encodePacked(chainActionId++, block.chainid, address(this), block.timestamp)));
    }

    /*** 
     * @notice: Check if transaction/batch of transactions don't violate sliding window limit & emit transactions
     * @param: txns - transactions to be made
    */
    function postMessage(BridgeTransfer[] memory txns) external payable {
        require(msg.value > 0, "BridgeTx: msg.value needs to be greater than 0");
        updateSlidingWindow(block.timestamp - (WINDOW_SIZE * 3600));

        uint256 totalTransactionAmount = 0;
        for (uint256 i = 0; i < txns.length; i++) {
            BridgeTransfer memory txn = txns[i];
            require(conversionRates[txn.foreignChainId] > 0, "BridgeTx: unsupported foreignChainId");
            totalTransactionAmount += txn.amount;
            require(totalAmount + totalTransactionAmount <= WINDOW_DEPOSIT_LIMIT, "BridgeTx: amount to be transferred exceeds slinding window transfer limit");

            emit BridgeTransaction(
                nextGlobalActionId(),
                txn.foreignAddress,
                txn.amount,
                block.timestamp,
                msg.sender,
                txn.foreignChainId,
                conversionRates[txn.foreignChainId],
                CONVERSION_DECIMALS
            );
        }

        require(msg.value >= totalTransactionAmount, "BridgeTx: total transaction amount does not match msg.value");
        transactions.push(Transaction(block.timestamp, totalTransactionAmount));
        totalAmount += totalTransactionAmount;
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

    function withdrawFunds(uint256 amount) public {
        require(msg.sender == owner, "BridgeTx: Not owner");
        require(address(this).balance >= amount, "BridgeTx: Insufficient funds");
        (bool sent, ) = owner.call{value: amount}("");
        require(sent, "Withdraw Failed");
    }
}