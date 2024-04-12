// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract State {
    struct MessageMeta{ 
        uint256 messageId;
        address clientAddr;
        uint256 clientChainId; 
        uint256 finalityFactor;
        uint256 userNonce;
        uint256 timestamp;
    }

    mapping (address implementations => bool status) internal initializationStatus;
    mapping (address client => uint256 messageId) internal clientMessageId;
    mapping(bytes32 => bool) internal sigCommittee;
    uint256 internal sigCommitteeSize = 0;
    uint256 internal baseFee;
    uint256 internal chainId;
}