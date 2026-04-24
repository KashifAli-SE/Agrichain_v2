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
    mapping(address=>bool) internal addressToUser;
    mapping(address=>uint256) internal addressToIndex;
    mapping(address=>Status) internal addressToStatus;

    event UserSignedUp(address indexed userAddress, string name, ROLE role, uint256 indexed time);
    event UserLoggedIn(address indexed userAddress, string name, ROLE role, uint256 indexed time);
    event UserDeleted(address indexed userAddress, uint256 indexed time);
    event UserUpdated(address indexed userAddress, string name, string contactNumber, string city, uint256 indexed time);
    event UserVerified(address indexed userAddress, uint256 indexed time);
    event UserRejected(address indexed userAddress, uint256 indexed time);
    event AdminAdded(address indexed adminAddress, string name, uint256 indexed time);
    event DocumentRegistrySet(address indexed documentRegistry, address indexed updatedBy, uint256 indexed time);
    event userRoleVerificationStatusUpdated(address indexed userAddress, ROLE role, VERIFICATION_STATUS verificationStatus, uint256 indexed time);

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
        USER memory nullUser= USER("Null", ROLE.NONE, "0000000000", "00000-0000000-0", "NullCity", "NullCountry", VERIFICATION_STATUS.VERIFIED);
        users.push(nullUser);
    }
    
    function login() external view returns(USER memory){
        require(addressToUser[msg.sender] == true,"Account does not exist");
        uint256 index=addressToIndex[msg.sender];
        USER memory currentUserData=users[index];
        return currentUserData;
    }

    function signUp(string memory _name, ROLE _role,
        string memory _contactNumber,
        string memory _CNIC,
        string memory _city,
        string memory _country) external returns(bool){
        require(addressToUser[msg.sender] == false, "Wallet Address already exists");
        require(_role != ROLE.ADMIN," can not sign Up as Admin");
        addressToUser[msg.sender] = true;
        addressToIndex[msg.sender] = users.length;
        USER memory user=USER(_name,_role, _contactNumber, _CNIC, _city, _country, VERIFICATION_STATUS.PENDING);
        users.push(user);
        emit UserSignedUp(msg.sender, _name, _role, block.timestamp);
        return true;
    }

    function signUpAsAdmin(string memory _name,
        string memory _contactNumber,
        string memory _CNIC,
        string memory _city,
        string memory _country,address _address) external onlyFirstAdmin returns(bool) {
        require(addressToUser[_address] == false, "user address already exist");
        USER memory user=USER(_name, ROLE.ADMIN, _contactNumber, _CNIC, _city, _country, VERIFICATION_STATUS.VERIFIED);
        addressToUser[_address]=true;
        addressToIndex[_address] = users.length;
        addressToStatus[_address]=Status.VERIFIED;
        users.push(user);
        emit AdminAdded(_address, _name, block.timestamp);
        return true;
    }

    function deleteAccount() public override returns (bool){
        require(addressToUser[msg.sender] == true, "Account address does not exist");
        uint256 index = addressToIndex[msg.sender];
        delete users[index];
        delete addressToUser[msg.sender];
        delete addressToIndex[msg.sender];
        delete addressToStatus[msg.sender];
        emit UserDeleted(msg.sender, block.timestamp);
        return true;
    }

    function updateAccount(string memory _name,
        string memory _contactNumber,
        string memory _city) external override returns(bool){
        require(addressToUser[msg.sender] == true,"Account address does not exist");
        uint256 userIndex=addressToIndex[msg.sender];
        USER storage user=users[userIndex];
        user.Name=_name;
        user.contactNumber=_contactNumber;
        user.city=_city;
        emit UserUpdated(msg.sender, _name, _contactNumber, _city, block.timestamp);
        return true;
    }

    function isFarmer(address user) external view returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        uint256 index=addressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.FARMER){
            return true;
        }else{
            return false;
        }
    }

    function isBuyer(address user) external view returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        uint256 index=addressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.BUYER){
            return true;
        }else{
            return false;
        }
    }

    function isShop(address user) external view returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        uint256 index=addressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.SHOPKEEPER){
            return true;
        }else{
            return false;
        }
    }

    function isGovernment(address user) external view returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        uint256 index=addressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.GOVERNMENT){
            return true;
        }else{
            return false;
        }
    }

    function isAdmin(address user) public view returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        uint256 index=addressToIndex[user];
        USER memory currentUserData=users[index];
        if(currentUserData.Role == ROLE.ADMIN ){
            return true;
        }else{
            return false;
        }
    }

    function isActiveUser(address user) external view returns(bool){
        return addressToUser[user] == true;

    }

    function isVerified(address user) external view override returns(bool){
        require(addressToUser[user] == true, "Account address does not exist");
        return addressToStatus[user] == Status.VERIFIED;
    }
    function verifyRole(address _address) external override onlyFirstAdminOrDocumentRegistry returns (bool){
        require(addressToUser[_address] == true, "Not A user");
        uint256 index=addressToIndex[_address];
        USER storage user=users[index];
        require(user.verificationStatus == VERIFICATION_STATUS.APPLIED, "verificationStatus is not applied");
        user.verificationStatus=VERIFICATION_STATUS.VERIFIED;
        addressToStatus[_address]=Status.VERIFIED;
        emit UserVerified(_address, block.timestamp);
        emit userRoleVerificationStatusUpdated(_address, user.Role, user.verificationStatus, block.timestamp);
        return true;
    }

    function rejectRole(address _address) external override onlyFirstAdminOrDocumentRegistry returns (bool){
        require(addressToUser[_address] == true, "Not A user");
        uint256 index=addressToIndex[_address];
        USER storage user=users[index];
        require(user.verificationStatus == VERIFICATION_STATUS.APPLIED, "verificationStatus is not applied");
        user.verificationStatus=VERIFICATION_STATUS.REJECTED;
        addressToStatus[_address]=Status.NOT_VERIFIED;
        emit userRoleVerificationStatusUpdated(_address, user.Role, user.verificationStatus, block.timestamp);
        return true;
    }

    function appliedForVerification(address _address) external onlyFirstAdminOrDocumentRegistry returns(bool) {
        uint256 index=addressToIndex[_address];
        USER storage user=users[index];
        user.verificationStatus=VERIFICATION_STATUS.APPLIED;
        emit userRoleVerificationStatusUpdated(_address, user.Role, user.verificationStatus, block.timestamp);
        return true;
    }

    function getUserId(address _address) external view returns(uint256) {
        require(addressToUser[_address] == true, "Not A user");
        uint256 index=addressToIndex[_address];
        return index;
    }

    function setDocumentRegistry(address _address) external returns(bool) {
        require(_address != address(0), "Not A Valid Address");
        require(isAdmin(msg.sender) == true, "Only Admin can set Document Registry");
        documentRegistryContract_address= _address;
        documentRegistryContract=DocumentRegistry(_address);
        emit DocumentRegistrySet(_address, msg.sender, block.timestamp);
        return true;
    }

    function getDocumentRegistry() external view returns(address) {
        return documentRegistryContract_address;
    }

}