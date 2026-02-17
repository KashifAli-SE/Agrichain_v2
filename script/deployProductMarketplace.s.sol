//SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

import {Script} from "../lib/forge-std/src/Script.sol";
import {UserManagement} from "../src/core/UserManagement.sol";
import {AccessControlled} from "src/core/AccessControlled.sol";
import {ProductMarketplace} from "../src/core/ProductMarketplace.sol";

contract  deployOtherContracts is Script{

    function setup() public {

    }

    function run() public {
        vm.startBroadcast();
        address _userManagement=vm.envAddress("usermanagement_contract_address");
        // address _treasury=vm.envAddress("Treasury_contract_address");
        // address _transectionManager=vm.envAddress("");
        // address _orderManager=vm.envAddress("");

        //CropMarketPlace cm=new CropMarketPlace(_userManagement);
        ProductMarketplace pm=new ProductMarketplace(_userManagement );

        vm.stopBroadcast();
    }
}