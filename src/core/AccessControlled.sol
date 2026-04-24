// SPDX-Licence-Provider: MIT

// This is considered an Exogenous, Decentralized, Anchored (pegged), Crypto Collateralized low volitility coin

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity 0.8.20;

import {IUserManagement} from "../interfaces/IUserManagement.sol";

abstract contract AccessControlled {

    IUserManagement um;

    constructor(address _usermanager){
        require(_usermanager != address(0), "Not A Valid Address");
        um=IUserManagement(_usermanager);
    }


    modifier onlyFarmer() {
        require(um.isActiveUser(msg.sender) != false, "Not a FARMER");
        require(um.isFarmer(msg.sender) != false, "Not a FARMER");
        _;
    }

    modifier onlyShop() {
        require(um.isActiveUser(msg.sender) != false, "Not a SHOPKEEPER");
        require(um.isShop(msg.sender) != false, "Not a SHOPKEEPER");
        _;
    }

    modifier onlyGovernment() {
        require(um.isActiveUser(msg.sender) != false, "Not a FARMER");
        require(um.isGovernment(msg.sender) != false, "Not a FARMER");
        _;
    }

    modifier onlyBuyer() {
        require(um.isActiveUser(msg.sender) != false, "Not a FARMER");
        require(um.isBuyer(msg.sender) != false, "Not a FARMER");
        _;
    }

    modifier onlyAdmin() {
        require(um.isActiveUser(msg.sender) != false, "Not a FARMER");
        require(um.isAdmin(msg.sender) != false, "Not a FARMER");
        _;
    }

    modifier onlyAdminOrShop() {
        require(um.isActiveUser(msg.sender) != false , "Not a FARMER");
        require(um.isShop(msg.sender) || um.isAdmin(msg.sender) , "Not a Shop or Admin");
        _;
    }

    modifier onlyActiveUser() {
        require(um.isActiveUser(msg.sender) != false, "Not a FARMER");
        _ ;
    }

    modifier onlyFarmerOrBuyer() {
        require(um.isActiveUser(msg.sender), "Not an ActiveUser");
        require(um.isFarmer(msg.sender) || um.isBuyer(msg.sender), "Not a FARMER or BUYER");
        _;
    }

    modifier onlyFarmerOrShop() {
        require(um.isActiveUser(msg.sender) , "Not an ActiveUser");
        require(um.isFarmer(msg.sender) || um.isShop(msg.sender), "Not a FARMER or BUYER");
        _;
    }

    modifier onlyShopOrBuyer() {
        require(um.isActiveUser(msg.sender) , "Not an ActiveUser");
        require(um.isShop(msg.sender) || um.isBuyer(msg.sender), "Not a SHOP or BUYER");
        _;
    }

    modifier onlyVerified() {
        require(um.isActiveUser(msg.sender) , "Not an ActiveUser");
        require(um.isVerified(msg.sender) , "Not a Verified User");
        _;
    }

    modifier onlyAdminOrDocumentRegistry() {
        require(um.isActiveUser(msg.sender) , "Not an ActiveUser");
        require(um.isAdmin(msg.sender) , "Not an Admin");
        _;
    }

    

}