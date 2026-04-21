// SPDX-Licence-Identifier: MIT

import {IUserManagement} from "./IUserManagement.sol";

pragma solidity 0.8.20;

interface IComplainRegisty{

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

    function submitReport(uint256 _orderID, address _buyer, address _seller) external returns(bool);

    function resolveReportToBuyer(uint256 reportId) external returns(bool);

    function resolveReportToSeller(uint256 reportId) external returns(bool);

    function rejectReport(uint256 reportId) external returns(bool);

    function withDrawReport(uint256 reportId) external returns(bool);

    function getReportStatus(uint256 reportId) external view returns(ReportStatus);


}