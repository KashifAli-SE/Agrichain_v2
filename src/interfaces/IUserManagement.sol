//SPDX-Licence-Provider: MIT
pragma solidity 0.8.20;

interface IUserManagement {

    //event LoginSuccessful("user login successful");
    //event signUp("user signedUP");
    //event deleteAccount("Account deleted");
    //event updateAccount("Account details updated");

    enum ROLE{
        NONE,
        FARMER,
        BUYER,
        SHOPKEEPER,
        GOVERNMENT,
        ADMIN
    }

    struct USER{
        string Name;
        ROLE Role;
        string contactNumber;
        string CNIC;
        string city;
        string Country;
    }

    function login() external view returns(USER memory);

    function signUp(USER memory user ) external returns(bool);

    function deleteAccount() external returns(bool);

    function updateAccount(USER memory user) external returns(bool);

    function isFarmer(address) external view returns(bool);

    function isShop(address) external view returns(bool);

    function isBuyer(address) external view returns(bool);
    
    function isGovernment(address) external view returns(bool);

    function isAdmin(address) external view returns(bool);

    function isActiveUser(address) external view returns(bool);

    function verifyRole(address) external returns(bool);

    function submitRoleDetails() external returns (bool);
    
}