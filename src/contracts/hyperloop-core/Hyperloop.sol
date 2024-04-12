// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol"; //@dev: Library

contract Hyperloop is ERC1967Proxy {
    constructor(address _implementationAddr, bytes memory _data) 
    ERC1967Proxy(_implementationAddr, _data)
    {}

    receive() external payable{} 
}