// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {Helpers} from "./Helpers.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol"; //@dev: Library


contract GovernanceLogic is Helpers{
    using Address for address payable;
    /////////////////////////////////////////////////////////////////////
    ///                          Governance logics                    ///
    /////////////////////////////////////////////////////////////////////
    function changeGovernanceAddress(address _governanceAddr) public {
        checkCallerIsGovernance();
        updateGovernanceAddr(_governanceAddr);
    }

    function setBaseFee(uint256 fee) public {
        checkCallerIsGovernance();
        updateBaseFee(fee);
    }

    // @NOTICE : recipient is governance in most of the cases.
    function withdrawFee(address recipient, uint256 amount) public {
        checkCallerIsGovernance();
        checkZeroAddr(recipient);
        checkZeroValue(amount);

        payable(recipient).sendValue(amount);

    }

    function updateChainIdAfterFork(uint256 newChainId) public {
        checkCallerIsGovernance();
        if (!checkIsForkChain()){
            revert Impl_Not_a_Fork_Chain();
        }
        setChainId(newChainId);
    }
}