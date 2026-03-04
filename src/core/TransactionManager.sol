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
import {Treasury} from "./Treasury.sol";

contract TransactionManager is ITransactionManager,AccessControlled{

    mapping(address=> uint256[]) addressToTransectionsIDs;
    Transaction[] transactions;
    uint256 transectionCounter=0;
    mapping(uint256=>uint256) transactionIDtodTransactionArrayIndex;

    address treasury_address;
    Treasury treasury_contract_address;

    event TransactionAdded( uint256 indexed transactionID, uint256 indexed orderID,address indexed seller, address buyer, uint256 amountTransferred);

    constructor(address _usermanager) AccessControlled(_usermanager){

    }


/*  struct Transaction{
        uint256 transactionID;
        uint256 orderID;
        address seller;
        address buyer;
        uint256 productId;
        uint256 amountTransferred;
    } */

    modifier onlyTreasury(){
        require(msg.sender == treasury_address, "Not a treasury");
        _;
    }


    function addTransaction(uint256 _orderID, address payable _seller, address payable _buyer,uint256 _amountTransfered) external onlyTreasury override returns(bool){
        Transaction memory newTransaction= Transaction(transectionCounter,_orderID, _seller,_buyer,_amountTransfered);
        addressToTransectionsIDs[_seller].push(transectionCounter);
        addressToTransectionsIDs[_buyer].push(transectionCounter);
        transactionIDtodTransactionArrayIndex[transectionCounter]=transactions.length;
        transactions.push(newTransaction);
        emit TransactionAdded(transectionCounter,_orderID,_seller,_buyer,_amountTransfered);
        return true;
    }

 

    function reportTransection(uint256 transactionID, address _reported, address accused,string memory reason) external returns(bool){

    }

     ///////////////////////////////////////////////
    //////////-------SETTERS--------///////////////
    //////////////////////////////////////////////

    function setTreasury(address _treasury) external returns(bool) {
        treasury_address=payable(_treasury);
        treasury_contract_address=Treasury(payable(treasury_address));

    }

    ///////////////////////////////////////////////
    //////////-------GETTERS--------///////////////
    //////////////////////////////////////////////


    function getTransactions() external override view returns(Transaction[] memory){
        return transactions;

    }

    function getTransactionByID(uint256 _transactionId) external override view returns(Transaction memory){
        uint256 index=transactionIDtodTransactionArrayIndex[_transactionId];
        return transactions[index];
    }
        
    function getTransactionsByUser(address user) external override view returns(uint256[] memory){
        return addressToTransectionsIDs[user];
    }



}