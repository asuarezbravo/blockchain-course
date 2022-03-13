// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ICOToken.sol";

contract Crowdsale {
    address public owner;

    ICOToken public token;

    uint256 public icoEndTime;

    uint256 public tokenRate;
    uint256 public fundingGoal;

    uint256 public tokensRaised;
    uint256 public etherRaised;

    modifier whenIcoCompleted() {
        require(isCompleted(), "ICO has not been completed yet");
        _;
    }
    modifier whenNoIcoCompleted() {
        require(!isCompleted(), "ICO has been completed already");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    receive() external payable {
        buy();
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        uint256 _icoEndSeconds,
        uint256 _tokenRate
    ) {
        require(_icoEndSeconds > 0 && _tokenRate > 0);

        icoEndTime = block.timestamp + _icoEndSeconds;
        tokenRate = _tokenRate;
        owner = msg.sender;
        token = new ICOToken(_name, _symbol, _decimals, _supply, address(this));
    }

    function buy() public payable whenNoIcoCompleted {
        uint256 etherReceived = msg.value;

        uint256 tokensToBuy = (etherReceived / 1 ether) *
            tokenRate *
            (10**token.decimals());

        // Check if we have exceeded the funding goal to refund the exceeding tokens and ether
        if (tokensRaised + tokensToBuy > token.totalSupply()) {
            uint256 exceedingTokens = tokensRaised +
                tokensToBuy -
                token.totalSupply();
            uint256 exceedingEther;

            // Convert the exceedingTokens to ether and refund that ether
            exceedingEther =
                (exceedingTokens * 1 ether) /
                tokenRate /
                token.decimals();

            payable(msg.sender).transfer(exceedingEther);

            // Change the tokens to buy to the new number
            tokensToBuy -= exceedingTokens;

            // Update the counter of ether used
            etherReceived -= exceedingEther;
        }

        // Send the tokens to the buyer
        token.transfer(msg.sender, tokensToBuy);

        // Increase the tokens raised and ether raised state variables
        tokensRaised += tokensToBuy;
        etherRaised += etherReceived;
    }

    function isCompleted() public view returns (bool) {
        return
            tokensRaised >= token.totalSupply() || block.timestamp > icoEndTime;
    }

    function extractEther() public whenIcoCompleted onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
