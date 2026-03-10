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
import {DocumentRegistry} from "./DocumentRegistry.sol"; 

contract UserManagement is IUserManagement {

    USER[] internal users;

    // USER MAPPINGS
    mapping(address=>bool) internal AddressToUser;
    mapping(address=>uint256) internal AddressToIndex;


    address documentRegistryContract_address;
    DocumentRegistry documentRegistryContract;

    modifier onlyFirstAdmin(){
        require(msg.sender == firstAdmin, "Caller is not first Admin");
        _;
    }

    modifier onlyFirstAdminOrDocumentRegistry() {
        require(msg.sender == firstAdmin || msg.sender == documentRegistryContract_address,
         "Invalid Caller, netither firstAdmin nor DocRegistry");
        _;
    }

    address firstAdmin;

    constructor() {
        firstAdmin= msg.sender;

    }
    
    function login() external view returns(USER memory){
        require(AddressToUser[msg.sender] == true,"Account does not exist");
        uint256 index=AddressToIndex[msg.sender];
        USER memory currentUserData=users[index];
        return currentUserData;
    }

    function signUp(string memory _name, ROLE _role,
        string memory _contactNumber,
        string memory _CNIC,
        string memory _city,
        string memory _country) external returns(bool){
        require(AddressToUser[msg.sender] == false, "Wallet Address already exists");
        require(_role != ROLE.ADMIN," can not sign Up as Admin");
        AddressToUser[msg.sender] = true;
        AddressToIndex[msg.sender] = users.length;
        USER memory user=USER(_name,_role, _contactNumber, _CNIC, _city, _country, VERIFICATION_STATUS.PENDING);
        users.push(user);
        return true;
    }

    function signUpAsAdmin(USER memory user, address _address) external onlyFirstAdmin returns(bool) {
        require(AddressToUser[_address] == false, "user address already exist");
        require(user.Role == ROLE.ADMIN, "USER ROLE IS NOT ADMIN");
        AddressToUser[_address]=true;
        AddressToIndex[_address] = users.length;
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

    function verifyRole(address _address) external override onlyFirstAdminOrDocumentRegistry returns (bool){
        require(AddressToUser[_address] == true, "Not A user");
        uint256 index=AddressToIndex[_address];
        USER storage user=users[index];
        require(user.verificationStatus == VERIFICATION_STATUS.APPLIED, "verificationStatus is not applied");
        user.verificationStatus=VERIFICATION_STATUS.VERIFIED;
        return true;
    }

    function rejectRole(address _address) external override onlyFirstAdminOrDocumentRegistry returns (bool){
        require(AddressToUser[_address] == true, "Not A user");
        uint256 index=AddressToIndex[_address];
        USER storage user=users[index];
        require(user.verificationStatus == VERIFICATION_STATUS.APPLIED, "verificationStatus is not applied");
        user.verificationStatus=VERIFICATION_STATUS.REJECTED;
        return true;
    }

    function appliedForVerification(address _address) external onlyFirstAdminOrDocumentRegistry returns(bool) {
        uint256 index=AddressToIndex[_address];
        USER storage user=users[index];
        user.verificationStatus=VERIFICATION_STATUS.APPLIED;
    }

    function getUserId(address _address) external view returns(uint256) {
        require(AddressToUser[_address] == true, "Not A user");
        uint256 index=AddressToIndex[_address];
        USER storage user=users[index];
        
    }

    function setDocumentRegistry(address _address) external onlyFirstAdmin returns(bool) {
        documentRegistryContract_address= _address;
        documentRegistryContract=DocumentRegistry(_address);
        return true;
    }

    function getDocumentRegistry() external view returns(address) {
        return documentRegistryContract_address;
    }

}