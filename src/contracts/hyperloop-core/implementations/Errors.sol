// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Errors {
    // errors
    error Impl_Caller_Is_Not_Governance();
    error Impl_Implementation_Already_Initialized();
    error Impl_Zero_Value_Specified();
    error Impl_Invalid_Address();
    error Impl_Insufficient_BaseFee();
    error Impl_Insufficient_Funds();
    error Impl_Incorrect_Chain_Id();
    error Impl_Not_a_Fork_Chain();

    error Impl_Invalid_Hypernova_Version();
}