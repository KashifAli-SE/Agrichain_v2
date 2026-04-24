// SPDX-Licence-Identifier: MIT

pragma solidity 0.8.20;

interface IDocumentRegistry {

    enum DocType {
        NONE,
        // Identity
        CNIC,
        SMART_CNIC,
        PASSPORT,
        
        // Farmer / Agriculture
        LAND_OWNERSHIP_FARD,
        LAND_REGISTRY_DEED,
        KISAN_CARD,
        TENANCY_AGREEMENT,
        IRRIGATION_PERMIT,

        // // Transport / Logistics
        // DRIVING_LICENSE,
        // VEHICLE_REGISTRATION,
        // TRANSPORT_PERMIT,

        // Business / Dealer
        BUSINESS_REGISTRATION,
        SHOP_LICENSE,
        Dealer_License,
        GOVT_EMPLOYEE_ID

    }

    struct Document {
        address owner;
        string encryptedCID;
        bytes32 hash;  // to verify the originality of the document on ipfs and onchain proof
        DocType docType;
        }

    function addDocument(string memory _encryptedCID, bytes32  _hash, DocType _docType) external; 

    function getDocumentsByUser(address _address) external  returns(Document memory);

}