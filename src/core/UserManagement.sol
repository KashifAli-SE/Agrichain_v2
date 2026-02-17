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

contract UserManagement is IUserManagement {

    USER[] internal users;

    mapping(address=>bool) internal AddressToUser;
    mapping(address=>uint256) internal AddressToIndex;
    
    function login() external view returns(USER memory){
        require(AddressToUser[msg.sender] == true,"Account does not exist");
        uint256 index=AddressToIndex[msg.sender];
        USER memory currentUserData=users[index];
        return currentUserData;
    }

    function signUp(USER memory user ) external returns(bool){
        require(AddressToUser[msg.sender] == false, "Wallet Address already exists");
        AddressToUser[msg.sender] = true;
        AddressToIndex[msg.sender] = users.length;
        users.push(user);
        return true;
    }

    function deleteAccount() public override returns (bool){
        require(AddressToUser[msg.sender] == true, "Account address does not exist");
        uint256 index = AddressToIndex[msg.sender];
        delete users[index];
        delete AddressToUser[msg.sender];
        delete AddressToIndex[msg.sender];
        return true;
    }

    function updateAccount(USER memory user) external override returns(bool){
        require(AddressToUser[msg.sender] == true,"Account address does not exist");
        uint256 userIndex=AddressToIndex[msg.sender];
        users[userIndex]=user;
        return true;
    }

    function isFarmer(address user) external view returns(bool){
        require(AddressToUser[user] == true, "Account address does not exist");
        uint256 index=AddressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.FARMER){
            return true;
        }else{
            return false;
        }
    }

    function isBuyer(address user) external view returns(bool){
        require(AddressToUser[user] == true, "Account address does not exist");
        uint256 index=AddressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.BUYER){
            return true;
        }else{
            return false;
        }
    }

    function isShop(address user) external view returns(bool){
        require(AddressToUser[user] == true, "Account address does not exist");
        uint256 index=AddressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.SHOPKEEPER){
            return true;
        }else{
            return false;
        }
    }

    function isGovernment(address user) external view returns(bool){
        require(AddressToUser[user] == true, "Account address does not exist");
        uint256 index=AddressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.GOVERNMENT){
            return true;
        }else{
            return false;
        }
    }

    function isAdmin(address user) external view returns(bool){
        require(AddressToUser[user] == true, "Account address does not exist");
        uint256 index=AddressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.ADMIN ){
            return true;
        }else{
            return false;
        }
    }

    function isActiveUser(address user) external view returns(bool){
        return AddressToUser[user] == true;
    }

    function verifyRole(address) external override returns (bool){
        

    }

    function submitRoleDetails() external override returns (bool)
    {
        
    }
}