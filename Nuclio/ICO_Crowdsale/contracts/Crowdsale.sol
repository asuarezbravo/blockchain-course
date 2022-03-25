// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ICOToken.sol";

contract Crowdsale {
    address public owner;
    ICOToken public token;
    uint256 public icoEndTime;
    uint256 public tokenRate; // numero de tokens por Ether recibido (Ether = 10**18 weis)

    uint256 public tokensSold;
    uint256 public etherRaised;

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
        uint256 _tokenRate
    ) {
        owner = msg.sender;
        token = new ICOToken(_name, _symbol, _decimals, _supply, address(this));
        icoEndTime = block.timestamp + _secondsIco;
        tokenRate = _tokenRate;
    }

    receive() external payable {
        buy();
    }

    function buy() public payable whenNoIcoCompleted {
        uint256 etherReceived = msg.value; // weis

        uint256 tokensToBuy = (etherReceived / 1 ether) *
            tokenRate *
            (10**token.decimals());

        if (tokensSold + tokensToBuy > token.totalSupply()) {
            uint256 exceedingTokens = tokensSold +
                tokensToBuy -
                token.totalSupply();
            uint256 exceedingEther = (exceedingTokens * 1 ether) /
                tokenRate /
                (10**token.decimals());
            payable(msg.sender).transfer(exceedingEther);

            tokensToBuy -= exceedingTokens;
            etherReceived -= exceedingEther;
        }

        token.transfer(msg.sender, tokensToBuy);

        tokensSold += tokensToBuy;
        etherRaised += etherReceived;
    }

    function withdrawEtherRaised() public whenIcoCompleted {
        require(msg.sender == owner);
        payable(owner).transfer(address(this).balance);
    }

    function icoCompleted() public view returns (bool) {
        return
            block.timestamp > icoEndTime || tokensSold >= token.totalSupply();
    }
}
