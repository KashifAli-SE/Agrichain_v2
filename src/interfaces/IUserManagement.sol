//SPDX-Licence-Provider: MIT
pragma solidity 0.8.20;

interface IUserManagement {
    enum ROLE{
        NONE,
        FARMER,
        BUYER,
        SHOPKEEPER,
        GOVERNMENT,
        ADMIN
    }

    enum VERIFICATION_STATUS{
        PENDING,
        APPLIED,
        VERIFIED,
        REJECTED
    }

    enum Status{
        NOT_VERIFIED,
        VERIFIED
   }

    struct USER{
        string Name;
        ROLE Role;
        string contactNumber;
        string CNIC;
        string city;
        string Country;
        VERIFICATION_STATUS verificationStatus;
    }

    function login() external view returns(USER memory);

    function signUp( string memory Name, ROLE Role, string memory contactNumber,
        string memory CNIC,
        string memory city,
        string memory Country) external returns(bool);

    function deleteAccount() external returns(bool);

    function updateAccount(string memory _name, string memory _contactNumber, string memory _city) external returns(bool);

    function isFarmer(address) external view returns(bool);

    function isShop(address) external view returns(bool);

    function isBuyer(address) external view returns(bool);
    
    function isGovernment(address) external view returns(bool);

    function isAdmin(address) external view returns(bool);

    function isActiveUser(address) external view returns(bool);

    function isVerified(address) external view returns(bool);

    function verifyRole(address) external returns(bool);

    function rejectRole(address _address) external returns (bool);

}