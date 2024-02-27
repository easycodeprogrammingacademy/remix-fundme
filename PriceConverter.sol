// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {AggregatorV3Interface} from "@chainlink/contracts@0.8.0/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getEthToUsdPrice() internal view returns (uint256) {
        // Address, Abi
        AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        uint8 decimals = dataFeed.decimals();
        (/* uint80 roundID */,
            int256  answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return uint256(answer) * (10 ** (18 - decimals));
    }

    function convertEthToUsd(uint256 ethAmount) internal view returns (uint256) {
        uint256 currentEthPrice = getEthToUsdPrice();
        return (ethAmount * currentEthPrice) / 1e18;
    }
}
