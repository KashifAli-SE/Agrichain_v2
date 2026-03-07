// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library PriceConverter {

    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer); // price with 8 decimals
    }

    // ETH -> USD conversion
    // ethAmount is in WEI (1e18)
    // returns USD amount (whole number like 50)
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {

        uint256 ethPrice = getPrice(priceFeed); // 8 decimals

        // normalize: 18 (ETH) + 8 (price)
        uint256 usdAmount = (ethAmount * ethPrice) / 1e26;

        return usdAmount;
    }

    // USD -> ETH conversion
    // usdAmount is whole number like 50
    // returns ETH amount in WEI
    function getUSDtoEth(
        uint256 usdAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {

        uint256 ethPrice = getPrice(priceFeed); // 8 decimals

        // normalize decimals: 18 + 8 = 26
        uint256 ethAmount = (usdAmount * 1e26) / ethPrice;

        return ethAmount;
    }
}