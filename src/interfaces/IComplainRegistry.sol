// SPDX-Licence-Identifier: MIT

import {IUserManagement} from "./IUserManagement.sol";

pragma solidity 0.8.20;

interface IComplainRegisty{


    function submitReport() external returns(bool);

    function resolveReportToBuyer() external returns(bool);

    function resolveReportToSeller() external returns(bool);

    function rejectReport() external returns(bool);

    function withDrawReport() external returns(bool);

    function getReportStatus() external view returns(bool);


}