// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

interface IHyperloop {
    struct MessageMeta{ 
        uint256 messageId;
        address clientAddr;
        uint256 clientChainId; 
        uint256 finalityFactor;
        uint256 userNonce;
        uint256 timestamp;
    }
    
    event MessagePosted(address indexed client, bytes messageMeta, bytes messageData);


    error Impl_Caller_Is_Not_Governance();
    error Impl_Implementation_Already_Initialized();
    error Impl_Zero_Value_Specified();
    error Impl_Invalid_Address();
    error Impl_Insufficient_BaseFee();
    error Impl_Insufficient_Funds();

    function initialize(address _governanceAddr, uint256 _baseFee, uint256 _chainId, bytes32[] memory _sigCommittee) external ;
    function upgradeHyperloopImplementation(address _newImplementation, bytes memory _data) external;
    
    function changeGovernance(address _governanceAddr) external;
    function setBaseFee(uint256 fee) external;
    function withdrawFee(address recipient, uint256 amount) external;

    function getCurrentImplementation() external view returns (address);
    function getGovernanceAddress() external view returns(address);
    function isInitialized(address _impl) external view returns(bool);
    function getCurrentBaseFee() external view returns (uint256);
    function getChainId() external view returns (uint256);

    function postMessage(uint256 userNonce, bytes memory messageData, uint256 finalityFactor) external payable returns(uint256 messageId);

    // Message.sol
    function scanAndVerifyData(bytes32 publicKey, bytes memory sig, bytes memory encodedMessage) external returns (bool success, MessageMeta memory messageMeta, bytes memory messageData, bytes memory _error);

}