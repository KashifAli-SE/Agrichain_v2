// SPDX-Licence-Identifier: MIT


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

import {ITransactionManager} from "../interfaces/ITransactionManager.sol";
import {AccessControlled} from "./AccessControlled.sol";

contract TransactionManager is ITransactionManager,AccessControlled{

    mapping(address=> uint256[]) addressToTransectionsIDs;
    Transaction[] transactions;
    
    constructor(address _usermanager) AccessControlled(_usermanager){

    }

    function addtransaction(Transaction memory) external override returns(bool){

    }

    function getTransactions() external override view returns(bool){

    }

    function getTransactionsByID() external override view returns(bool){}

    function getTransactionsByUser() external override view returns(bool){}

}