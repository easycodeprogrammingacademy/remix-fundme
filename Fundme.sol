// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "./Priceconverter.sol";

error NotOwner();

contract Fundme {
    using Priceconverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address public immutable owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
        // require(convertEthToUsd(msg.value) >= MINIMUM_USD, "You need to send more ETH!");
        require(msg.value.convertEthToUsd() >= MINIMUM_USD, "You need to send more ETH!");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotOwner();
        }
        _;
    }

    function withdraw() public onlyOwner {
        for(uint256 index = 0; index < funders.length; index ++) {
            addressToAmountFunded[funders[index]] = 0;
        }
        funders = new address[](0);
        (bool callSuccess, ) = payable(msg.sender).call{ value: address(this).balance }("");
        require(callSuccess, "Withdraw Failed!!");
    }

    // function getEthToUsdPrice() public view returns (uint256) {
    //     // Address, Abi
    //     AggregatorV3Interface dataFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    //     uint8 decimals = dataFeed.decimals();
    //     (/* uint80 roundID */,
    //         int256  answer,
    //         /*uint startedAt*/,
    //         /*uint timeStamp*/,
    //         /*uint80 answeredInRound*/
    //     ) = dataFeed.latestRoundData();
    //     return uint256(answer) * (10 ** (18 - decimals));
    // }

    // function convertEthToUsd(uint256 ethAmount) public view returns (uint256) {
    //     uint256 currentEthPrice = getEthToUsdPrice();
    //     return (ethAmount * currentEthPrice) / 1e18;
    // }

    // If someone send the contract Ether
    // Is msg.data empty? 
    // Empty -> fallback()
    // Has data -> receive()
    //      -> no receive() function -> fallback()

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
}
