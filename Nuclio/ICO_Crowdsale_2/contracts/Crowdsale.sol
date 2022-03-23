// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ICOToken.sol";

contract Crowdsale {
    address public owner;

    ICOToken public token;

    uint256 public icoEndTime;

    uint256 public tokenRate;
    uint256 public fundingGoal;

    uint256 public tokensSold;
    uint256 public tokensPaymentRaised;

    ERC20 public tokenPayment;

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

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        uint256 _icoEndSeconds,
        uint256 _tokenRate,
        address _tokenPayment
    ) {
        require(_icoEndSeconds > 0 && _tokenRate > 0);

        icoEndTime = block.timestamp + _icoEndSeconds;
        tokenRate = _tokenRate;
        tokenPayment = ERC20(_tokenPayment);
        owner = msg.sender;
        token = new ICOToken(_name, _symbol, _decimals, _supply, address(this));
    }

    function buy(uint256 _tokensPaymentReceived) public payable whenNoIcoCompleted {

        uint256 tokensToBuy = (_tokensPaymentReceived / 10**tokenPayment.decimals()) *
            tokenRate *
            (10**token.decimals());

        // Check if we have exceeded the funding goal to refund the exceeding tokens and ether
        if (tokensSold + tokensToBuy > token.totalSupply()) {
            uint256 exceedingTokensSold = tokensSold +
                tokensToBuy -
                token.totalSupply();

            // Convert the exceedingTokens to ether and refund that ether
            uint256 exceedingTokensPayment =
                (exceedingTokensSold * 10**tokenPayment.decimals()) /
                tokenRate /
                10**token.decimals();

            // Change the tokens to buy to the new number
            tokensToBuy -= exceedingTokensSold;

            // Update the counter of ether used
            _tokensPaymentReceived -= exceedingTokensPayment;
        }

        // Send the tokens to the buyer
        token.transfer(msg.sender, tokensToBuy);

        //send payment tokens to contract
        tokenPayment.transferFrom(msg.sender, address(this), _tokensPaymentReceived);

        // Increase the tokens raised and ether raised state variables
        tokensSold += tokensToBuy;
        tokensPaymentRaised += _tokensPaymentReceived;
    }

    function isCompleted() public view returns (bool) {
        return
            tokensSold >= token.totalSupply() || block.timestamp > icoEndTime;
    }

    function extractEther() public whenIcoCompleted onlyOwner {
        tokenPayment.transfer(owner, tokensPaymentRaised);
    }
}
