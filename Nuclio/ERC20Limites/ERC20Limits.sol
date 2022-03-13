// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./ERC/ERC20.sol";

contract ERC20Limits is ERC20 {
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
        require(
            _minAmount < _maxAmount,
            "Maximum must be greater than minimum"
        );
        minAmount = _minAmount; // set minimun amount
        maxAmount = _maxAmount; // set maximum amount
        _mint(msg.sender, _supply); // mint and assign tokens
    }
}
