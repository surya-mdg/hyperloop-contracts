// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {UUPSUpgradeable} from "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import {Helpers} from "./Helpers.sol";

contract UpgradeLogic is UUPSUpgradeable, Helpers{
 
    /////////////////////////////////////////////////////////////////////
    ///                          Upgrade logics                       ///
    /////////////////////////////////////////////////////////////////////
    modifier  initializer() {
        address currentImpl = getCurrentImplementation();
        if (isInitialized(currentImpl)){
            revert Impl_Implementation_Already_Initialized();
        }
        setInitializationStatus(currentImpl);
        _;
    }


    // @dev: Initializer 
    // @param:  _governanceAddr - Governance contract which manages upgrades and funds
    function initialize(address _governanceAddr, uint256 _baseFee, uint256 _chainId, bytes32[] memory _sigCommittee) public initializer() { // @NOTICE: What about adding onlyProxy()?
        updateBaseFee(_baseFee);
        updateGovernanceAddr(_governanceAddr);
        setChainId(_chainId);

        //TODO: Confirm
        updateSigCommittee(_sigCommittee);
    }

    // @dev : Access control : Only Governance should have access
    function _authorizeUpgrade(address /*newImplementation*/) internal view override{
        checkCallerIsGovernance();
    }

    // @dev: Change Governance contract
    function upgradeHypernovaImplementation(address _newImplementation, bytes memory _data) public {
        checkCallerIsGovernance();
        upgradeToAndCall(_newImplementation, _data);
    }
   
}