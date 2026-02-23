// SPDX-Licence-Identifier: MIT


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

import {IComplainRegisty} from "../interfaces/IComplainRegistry.sol";

contract ComplaintRegistry is IComplainRegisty{

    enum ReportStatus{
        FILED,
        UNDER_REVIEWED,
        RESOLVED_BUYER,
        RESOLVED_SELLER,
        REJECTED,
        RESOLVED
    }

    struct report{
        uint256 reportID;
        uint256 orderID;
        address buyer;
        address seller;
        ReportStatus reportStatus;
        
        
    }
    
    function submitReport() external override returns(bool){

        } 

    function resolveReportToBuyer() external override returns(bool){

    }

    function resolveReportToSeller() external override returns(bool){

    }

    function rejectReport() external override returns(bool){

    }

    function withDrawReport() external override returns(bool){

    }

    function getReportStatus() external view override returns(bool){

    }
}