// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

import {IDocumentRegistry} from "../interfaces/IDocumentRegistry.sol";
import {UserManagement} from "./UserManagement.sol";
import {AccessControlled} from "./AccessControlled.sol";

contract DocumentRegistry is IDocumentRegistry,AccessControlled{

    address user_management_address;
    UserManagement userManagementContract;

    //DOCUMENT MAPPINGS
    // mapping(uint256 => Document) public documents;
    mapping(address => Document) public userDocs;

    constructor(address _um) AccessControlled(_um) {
        user_management_address = _um;
        userManagementContract=UserManagement(_um);
    }

    function addDocument(Document memory _document) public override {
        require(userManagementContract.isActiveUser(msg.sender) == true , "Not a VERIFIED User");
        userDocs[msg.sender]= _document;
        userManagementContract.appliedForVerification(msg.sender);
    }

    // function verifyUserDocuments() external onlyAdmin returns(bool) {}

    function getDocumentsByUser(address _address) external override view returns(Document memory) {
        return userDocs[_address];

        
    }

    function verifyUser(address _address) external onlyAdmin {
        userManagementContract.verifyRole(_address);
    }

    function rejectUser(address _address) external onlyAdmin {
        userManagementContract.rejectRole(_address);
    }


}