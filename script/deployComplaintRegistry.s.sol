//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {TransactionManager} from "../src/core/TransactionManager.sol";
import {ComplaintRegistry} from "../src/core/ComplaintRegistry.sol";

contract deployComplaintRegistry is Script{

        function setUp() external{

        }

        function run() external{
            address _usermanager = vm.envAddress("userManagementContractAddress");
            vm.startBroadcast();
            ComplaintRegistry cr = new ComplaintRegistry(_usermanager);

            vm.stopBroadcast();
           
        }

}