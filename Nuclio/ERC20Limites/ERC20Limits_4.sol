// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./ERC/ERC20.sol";
import "./Ownable.sol";

contract ERC20Limits_4 is ERC20, Ownable {
    uint256 public minAmount;
    uint256 public maxAmount;

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        uint256 _minAmount,
        uint256 _maxAmount
    ) ERC20(_name, _symbol, _decimals) {
        owner = msg.sender;
        setLimits(_minAmount, _maxAmount);
        _mint(msg.sender, _supply); // mint and assign tokens
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            amount >= minAmount,
            "Amount must be greater than or equal to minimum"
        );
        require(
            amount <= maxAmount,
            "Amount must be less than or equal to maximum"
        );
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function setLimits(uint256 _minAmount, uint256 _maxAmount)
        public
        onlyOwner
    {
        require(
            _minAmount < _maxAmount,
            "Maximum must be greater than minimum"
        );
        minAmount = _minAmount; // set minimun amount
        maxAmount = _maxAmount; // set maximum amount
    }
}
