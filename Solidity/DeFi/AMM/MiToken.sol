// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC/ERC20.sol";

contract MIAXToken is ERC20{
    constructor() ERC20("Token MIAX", "MIAX", 0) {
        _mint(msg.sender, 50);
    }
}
