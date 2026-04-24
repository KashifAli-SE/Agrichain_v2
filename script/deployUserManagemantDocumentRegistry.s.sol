//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {UserManagement} from "../src/core/UserManagement.sol";
import {DocumentRegistry} from "../src/core/DocumentRegistry.sol";

contract usermanager is Script{

    function setup() public {

    }

    function run() public {
        vm.startBroadcast();
        UserManagement um= new UserManagement();
        DocumentRegistry dr=new DocumentRegistry(address(um));
        vm.stopBroadcast();
    }
}