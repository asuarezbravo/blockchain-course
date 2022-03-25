// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.8;

import "./ICOToken.sol";
import "./ERC/ERC20.sol";

contract Crowdsale2 {
    address public owner;
    ICOToken public token;    
    ERC20 public tokenPayment;
    uint256 public icoEndTime;
    uint256 public tokenRate; // numero de tokens por Ether recibido (Ether = 10**18 weis)

    uint256 public tokensSold;
    uint256 public tokenPaymentRaised;

    modifier whenNoIcoCompleted() {
        require(!icoCompleted(), "Ico finalizada");
        _;
    }

    modifier whenIcoCompleted() {
        require(icoCompleted(), "Ico no completada");
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        uint256 _secondsIco,
        uint256 _tokenRate,
        address _tokenPaymentAddress
    ) {
        owner = msg.sender;
        token = new ICOToken(_name, _symbol, _decimals, _supply, address(this));
        icoEndTime = block.timestamp + _secondsIco;
        tokenRate = _tokenRate;
        tokenPayment = ERC20(_tokenPaymentAddress);
    }

    function buy(uint256 _tokensPayment) public payable whenNoIcoCompleted {
        uint tokensPaymentReceived = _tokensPayment; // weis

        uint tokensToBuy = tokensPaymentReceived / (10 ** tokenPayment.decimals()) * tokenRate * (10 ** token.decimals());

        if(tokensSold + tokensToBuy > token.totalSupply()) {
            uint exceedingTokens = tokensSold + tokensToBuy - token.totalSupply();
            uint exceedingTokensPayment = exceedingTokens * (10 ** tokenPayment.decimals()) / tokenRate / (10 ** token.decimals());
            //payable(msg.sender).transfer(exceedingEther);

            tokensToBuy -= exceedingTokens;
            tokensPaymentReceived -= exceedingTokensPayment;
        }

        token.transfer(msg.sender, tokensToBuy);
        tokenPayment.transferFrom(msg.sender, address(this), tokensPaymentReceived);

        tokensSold += tokensToBuy;
        tokenPaymentRaised += tokensPaymentReceived;
    }

    function withdrawEtherRaised() public whenIcoCompleted {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    function icoCompleted() public view returns(bool) {
       return block.timestamp > icoEndTime || tokensSold >= token.totalSupply();
    }
}