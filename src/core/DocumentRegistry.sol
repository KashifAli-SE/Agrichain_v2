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
        Document memory nullDocument= Document(address(0), bytes32(0), bytes32(0), "NullDocType");
        userDocs[address(0)]= nullDocument;
    }

    function addDocument(bytes32 _encryptedCID, bytes32  _hash, string memory _docType) public override {
        require(userManagementContract.isActiveUser(msg.sender) == true , "Not a VERIFIED User");
        Document memory _document = Document(msg.sender, _encryptedCID, _hash, _docType);
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