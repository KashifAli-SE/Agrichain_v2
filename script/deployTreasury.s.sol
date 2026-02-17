//SPDX-Licence-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";

import {Treasury} from "../src/core/Treasury.sol";

contract deployTransectionOrderManager is Script{

        function setUp() external{

        }

        function run() external{
            address _usermanager = vm.envAddress("usermanagement_contract_address");
            vm.startBroadcast();
            Treasury tre=new Treasury(_usermanager);
           vm.stopBroadcast();
           
        }

}