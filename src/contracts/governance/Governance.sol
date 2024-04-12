// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Implementation} from "../hyperloop-core/implementations/Implementation.sol";
import {Hyperloop} from "../hyperloop-core/Hyperloop.sol";

contract Governance{
    address public owner;
    constructor(){
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Only governance owner can call this");
        _;
    }
}