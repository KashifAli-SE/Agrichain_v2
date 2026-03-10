// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

interface IDocumentRegistry {

    struct Document {
        address owner;
        string cid;
        bytes32 hash;
        string docType;
        }

    function addDocument(Document memory _document) external ;

    function getDocumentsByUser(address _address) external view returns(Document memory);

    

}