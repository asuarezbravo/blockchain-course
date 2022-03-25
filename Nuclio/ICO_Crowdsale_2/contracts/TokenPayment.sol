// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ERC/ERC20.sol";

contract TokenPayment is ERC20 {

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _supply) ERC20(_name, _symbol, _decimals) {
        _mint(msg.sender, _supply);
    }
}
