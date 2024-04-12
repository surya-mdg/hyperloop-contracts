// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {State} from "./State.sol";
import {Ed25519} from "../../../../lib/encryption/Ed25519.sol";
//import {BytesLib} from "../../libraries/BytesLib.sol";

contract Message is State{
    //using BytesLib for bytes;

    /** encodedMessage - Bytes form of emitted event data 
    * bytes(address client, MessageMeta messageMeta, messageData )
    *  Verify encodeMessage and return the messageMeta and messageData to the client.
    * encodedMessage (bytes): <client address><messageMeta><messageData>
    */
    function scanAndVerifyData(bytes32 publicKey, bytes memory sig, bytes memory encodedMessage) public view returns (bool success, MessageMeta memory messageMeta, bytes memory messageData, bytes memory _error){
        //messageMeta = scanMessageMeta(encodedMessage);
        //messageData = scanMessageData(encodedMessage);
        success = verifyEncodedMessage(publicKey, sig, encodedMessage);

        if (!success){
            return (false, messageMeta, encodedMessage, "Verification Failed");
        }
        return (true, messageMeta, encodedMessage, "");
    }

    /*** Scans encodedMessage and messageData from it 
     * 
     */
    function scanMessageData(bytes memory encodeMessage) public pure returns (bytes memory messageData){
        ( , messageData, ) = abi.decode(encodeMessage, (address, bytes, MessageMeta));
    }
    function scanMessageMeta(bytes memory encodeMessage) public pure returns (MessageMeta memory messageMeta){
        ( , , messageMeta) = abi.decode(encodeMessage, (address, bytes, MessageMeta));
    }

    /*** 
     * @notice: Verifies the ed25519 signature
     * @param: publicKey - public key of the node that signed this message
     * @param: sig - ed25519 signature generated for the message
     * @param: message - message that has been signed using the node private key
    */
    function verifyEncodedMessage(bytes32 publicKey, bytes memory sig, bytes memory encodedMessage) public view returns (bool success){
        require(sigCommittee[publicKey], "hyperloop-core: signer not part of sig committee");

        bytes32 r;
        bytes32 s;
        assembly{
            r:= mload(add(sig,32))
            s:= mload(add(sig,64))
        }
        success = Ed25519.verify(publicKey, r, s, encodedMessage);
    }
}