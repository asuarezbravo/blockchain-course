// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";
import "./ERC20.sol";

contract Euro is ERC20, Ownable{

    constructor() Ownable() ERC20("Euro", "EUR", 2){
    }

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}