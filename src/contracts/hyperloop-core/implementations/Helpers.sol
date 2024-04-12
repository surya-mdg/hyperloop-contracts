// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol"; //@dev: Library
import {State} from "./State.sol";
import {Errors} from "./Errors.sol";


contract Helpers is State, Errors{
    /////////////////////////////////////////////////////////////////////
    ///                          Getters logics                       ///
    /////////////////////////////////////////////////////////////////////
    // Getters
    // @dev: Returns current active implementation address
    function getCurrentImplementation() public view returns (address){
        return ERC1967Utils.getImplementation();
    }

    // @dev: returns current governance contracts address
    function getGovernanceAddress() public view returns(address) {
        return ERC1967Utils.getAdmin();
    }

    function isInitialized(address _impl) public view returns(bool) {
        return initializationStatus[_impl];
    }

    function getCurrentBaseFee() public view returns (uint256){
        return baseFee;
    }

    function getChainId() public view returns (uint256) {
        return chainId;
    }
    
    /////////////////////////////////////////////////////////////////////
    ///                          Setters logics                       ///
    /////////////////////////////////////////////////////////////////////
    function setInitializationStatus(address _impl) internal {
        initializationStatus[_impl] = true;
    }
    function setChainId(uint256 _chainId) internal {
        checkZeroValue(_chainId);
        if (_chainId != block.chainid){
            revert Impl_Incorrect_Chain_Id();
        }
        chainId = _chainId;
    }
    function updateMessageId() internal returns(uint256 messageId){
        messageId = clientMessageId[msg.sender] + 1;
        clientMessageId[msg.sender] = messageId;
    }

    function updateBaseFee(uint256 fee) internal {
        checkZeroValue(fee);
        baseFee = fee;
    }

    function updateGovernanceAddr(address _governanceAddr) internal {
        ERC1967Utils.changeAdmin(_governanceAddr);
    }

    function updateSigCommittee(bytes32[] memory _signer) internal {
        for(uint256 i = 0; i < _signer.length; i++){
            sigCommittee[_signer[i]] = true;
        }
    }

    /////////////////////////////////////////////////////////////////////
    ///                          Checks                               ///
    /////////////////////////////////////////////////////////////////////
    
    function checkCallerIsGovernance() internal view returns (bool){
        if (msg.sender != getGovernanceAddress()){
            revert Impl_Caller_Is_Not_Governance();
        }
        return true;
    }

    function checkZeroValue(uint256 value) internal pure {
        if (value == 0){
            revert Impl_Zero_Value_Specified();
        }
    }
    function checkZeroAddr(address addr) internal pure {
        if (addr == address(0)){
            revert Impl_Invalid_Address();
        }
    }

    function checkIsForkChain() internal view returns(bool){
        return getChainId() != block.chainid;
    }
}