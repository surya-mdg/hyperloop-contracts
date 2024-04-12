// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol"; //@dev: Library
import {UpgradeLogic} from "./UpgradeLogic.sol";
import {GovernanceLogic} from "./GovernanceLogic.sol";
import {Message} from "./Message.sol";

/** @notice
* Admin == Governance

*/ 

contract Implementation is UpgradeLogic, GovernanceLogic, Message{
    // events
    event MessagePosted(address indexed client, bytes messageMeta, bytes messageData);
    
    /////////////////////////////////////////////////////////////////////
    ///                          Functions                            ///
    /////////////////////////////////////////////////////////////////////

    /*** 
     * @dev: postMessage() emits the event with user/client message
     * @param: userNonce - User nonce is a free variable for the user to track their own transfers
     * @param: messageData - a raw bytes of data, user/client has to format this data for their custom use. 
     *          (Ex: specifying destination chainId, etc)
     * @param: finalityFactor is the number of confirmations to be completed before sending message to receiver
     * @return: A unique messageId for every client/user that increments on every postMessage() call.
    */
    function postMessage(uint256 _userNonce, bytes memory messageData, uint256 _finalityFactor) public payable returns(uint256 _messageId){
        
        if (msg.value != baseFee) {
            revert Impl_Insufficient_BaseFee();
        }

        _messageId = updateMessageId();
        MessageMeta memory _messageMeta = MessageMeta({
            messageId: _messageId,
            clientAddr: msg.sender,
            clientChainId: getChainId(),
            finalityFactor: _finalityFactor,
            userNonce: _userNonce,
            timestamp: block.timestamp
        });
        bytes memory messageMeta = abi.encodePacked(
            _messageMeta.messageId,
            _messageMeta.clientAddr,
            _messageMeta.clientChainId,
            _messageMeta.finalityFactor,
            _messageMeta.userNonce,
            _messageMeta.timestamp
        );
        
        emit MessagePosted(msg.sender, messageMeta, messageData);
    }
}

