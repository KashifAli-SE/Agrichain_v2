// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

interface IDocumentRegistry {

    struct Document {
        address owner;
        bytes32 encryptedCID;
        bytes32 hash;  // to verify the originality of the document on ipfs and onchain proof
        string docType;
        }

    function addDocument(bytes32 _encryptedCID, bytes32  _hash, string memory _docType) external ;

    function getDocumentsByUser(address _address) external  returns(Document memory);

}