// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ERC/ERC20.sol";

contract ERC20Limites is ERC20 {
    uint256 public cantidadMinima;
    uint256 public cantidadMaxima;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_,
        uint256 cantidadMinima_,
        uint256 cantidadMaxima_
    ) ERC20(name_, symbol_, decimals_) {
        cantidadMinima = cantidadMinima_; // set minimun amount
        cantidadMaxima = cantidadMaxima_; // set maximum amount
        _mint(msg.sender, supply_); // mint and assign tokens
    }
}
