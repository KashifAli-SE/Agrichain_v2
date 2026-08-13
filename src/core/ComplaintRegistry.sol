// SPDX-License-Identifier: MIT


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
import {AccessControlled} from "./AccessControlled.sol";

contract ComplaintRegistry is IComplainRegisty, AccessControlled{
    
    report[] reports;
    uint256 reportCounter=0;
    mapping(uint256=>uint256) reportIDtoReportArrayIndex;
    mapping(uint256=>ReportStatus) reportIDtoReportStatus;

    
    event ReportSubmitted(uint256 indexed reportID, uint256 indexed orderID, address indexed buyer, address seller, uint256 timestamp);
    event ReportResolved(uint256 indexed reportID, ReportStatus status, uint256 indexed time);
    event ReportRejected(uint256 indexed reportID, uint256 indexed time);
    event ReportWithdrawn(uint256 indexed reportID, uint256 indexed time);
    event ReportResolvedToBuyer(uint256 indexed reportID, uint256 indexed time);
    event ReportResolvedToSeller(uint256 indexed reportID, uint256 indexed time);
    event ReportStatusChanged(uint256 indexed reportID, ReportStatus indexed newStatus, uint256 indexed time);



    constructor(address _usermanager) AccessControlled(_usermanager){
        report memory dummyReport= report(0,0,address(0),address(0),ReportStatus.FILED);
        reports.push(dummyReport);
        reportIDtoReportArrayIndex[0]=0;
        reportIDtoReportStatus[0]=ReportStatus.FILED;
        reportCounter=1;
    }

    function submitReport(uint256 _orderID, address _buyer, address _seller) external  onlyVerified override returns(bool){
        report memory newReport= report(reportCounter,_orderID,_buyer,_seller,ReportStatus.FILED);
        reportIDtoReportArrayIndex[reportCounter]=reports.length;
        reportIDtoReportStatus[reportCounter]=ReportStatus.FILED;
        reports.push(newReport);
        emit ReportSubmitted(reportCounter,_orderID,_buyer,_seller,block.timestamp);
        reportCounter++;
        return true;

    } 

    function resolveReportToBuyer(uint256 reportId) external onlyAdmin onlyVerified override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.RESOLVED_BUYER;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED_BUYER;
        require(rp.seller != address(0), "seller address is Null");
        return true;
        


    }

    function resolveReportToSeller(uint256 reportId) external onlyAdmin onlyVerified override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.RESOLVED_SELLER;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED_SELLER;
        require(rp.buyer != address(0), "buyer address is Null");
        return true;

    }

    function rejectReport(uint256 reportId) external onlyAdmin onlyVerified override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
            
        rp.reportStatus = ReportStatus.REJECTED;
        reportIDtoReportStatus[reportId] = ReportStatus.REJECTED;
        require(rp.buyer != address(0) && rp.seller != address(0), "buyer or seller address is Null");
        return true;

    }

    function withDrawReport(uint256 reportId) external onlyVerified override returns(bool){
        uint256 index=reportIDtoReportArrayIndex[reportId];
        report storage rp = reports[index];
        require(rp.buyer == msg.sender, "Only the report filer can withdraw");
        require(rp.reportStatus == ReportStatus.FILED, "Report is not in FILED status");
        rp.reportStatus = ReportStatus.RESOLVED;
        reportIDtoReportStatus[reportId] = ReportStatus.RESOLVED;
        emit ReportWithdrawn(reportId, block.timestamp);
        return true;
    }

    function getReportStatus(uint256 reportId) external view override returns(ReportStatus){
        return reportIDtoReportStatus[reportId];
    }
}