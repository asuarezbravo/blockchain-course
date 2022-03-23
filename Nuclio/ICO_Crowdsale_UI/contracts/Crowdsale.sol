// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8;

import "./ICOToken.sol";

contract Crowdsale {
    address public owner;

    ICOToken public token;

    uint256 public icoEndTime; // in seconds

    uint256 public tokenRate; // in tokens per ether (tokens/ether)

    uint256 public tokensSold; // up to total supply
    uint256 public etherRaised;

    event Sold(address _buyer, uint _tokensSold, uint _etherRaised, uint _totalSupply);

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

    // so users can just send Ether
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

    // only allow to buy while the ico is still running
    function buy() public payable whenNoIcoCompleted {
        uint256 etherReceived = msg.value; // in wei

        uint256 tokensToBuy = (etherReceived / 1 ether) * // we need to convert to ETH from wei
            tokenRate *
            (10 ** token.decimals()); // tokens are in the smallest unit

        // Check if we have exceeded the funding goal to refund the exceeding tokens and ether
        if (tokensSold + tokensToBuy > token.totalSupply()) {
            uint256 exceedingTokens = tokensSold +
                tokensToBuy -
                token.totalSupply(); // in the smallest unit

            // Convert the exceedingTokens to ether and refund that ether
            uint256 exceedingEther = exceedingTokens * 1 ether / tokenRate / token.decimals(); // in weis

            payable(msg.sender).transfer(exceedingEther);

            // Change the tokens to buy to the new number
            tokensToBuy -= exceedingTokens;

            // Update the counter of ether used
            etherReceived -= exceedingEther;
        }

        // Send the tokens to the buyer
        token.transfer(msg.sender, tokensToBuy);

        // Increase the tokens sold and ether raised state variables
        tokensSold += tokensToBuy;
        etherRaised += etherReceived;

        emit Sold(msg.sender, tokensSold, etherRaised, token.totalSupply());
    }

    // Ico is completed once total supply has been sold or ICO endtime has arrived
    function isCompleted() public view returns(bool) {
        return
        tokensSold >= token.totalSupply() || block.timestamp > icoEndTime;
    }

    // allow to withdraw funds raised once ico is completed
    function extractEther() public whenIcoCompleted onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}