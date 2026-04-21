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

    event ReportSubmitted(uint256 indexed reportID, uint256 indexed orderID, address indexed buyer, address seller, uint256 timestamp);

    report[] reports;
    uint256 reportCounter=0;
    mapping(uint256=>uint256) reportIDtoReportArrayIndex;
    mapping(uint256=>ReportStatus) reportIDtoReportStatus;

    
    function submitReport(uint256 _orderID, address _buyer, address _seller) external override returns(bool){
        report memory newReport= report(reportCounter,_orderID,_buyer,_seller,ReportStatus.FILED);
        reportIDtoReportArrayIndex[reportCounter]=reports.length;
        reportIDtoReportStatus[reportCounter]=ReportStatus.FILED;
        reports.push(newReport);
        emit ReportSubmitted(reportCounter,_orderID,_buyer,_seller,block.timestamp);
        reportCounter++;
        return true;

    } 

    function resolveReportToBuyer(uint256 reportId) external override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.RESOLVED_BUYER;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED_BUYER;
        require(rp.seller != address(0), "seller address is Null");
        return true;
        


    }

    function resolveReportToSeller(uint256 reportId) external override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.RESOLVED_SELLER;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED_SELLER;
        require(rp.buyer != address(0), "buyer address is Null");
        return true;

    }

    function rejectReport(uint256 reportId) external override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.REJECTED;
        reportIDtoReportStatus[reportId] = ReportStatus.REJECTED;
        require(rp.buyer != address(0) && rp.seller != address(0), "buyer or seller address is Null");
        return true;

    }

    function withDrawReport(uint256 reportId) external override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.RESOLVED;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED;
        require(rp.buyer != address(0) && rp.seller != address(0), "buyer or seller address is Null");
        return true;

    }

    function getReportStatus(uint256 reportId) external view override returns(ReportStatus){
        return reportIDtoReportStatus[reportId];


    }
}