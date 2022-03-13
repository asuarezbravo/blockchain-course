// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ERC/ERC20.sol";

contract ERC20Limites_3 is ERC20 {
    address public owner;
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
        require(
            cantidadMinima_ < cantidadMaxima_,
            "El maximo debe ser mayor que el minimo"
        );
        owner = msg.sender;
        cantidadMinima = cantidadMinima_; // set minimun amount
        cantidadMaxima = cantidadMaxima_; // set maximum amount
        _mint(msg.sender, supply_); // mint and assign tokens
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        require(
            amount >= cantidadMinima,
            "La cantidad debe ser mayor o igual que el minimo"
        );
        require(
            amount <= cantidadMaxima,
            "La cantidad debe ser menor o igual que el maximo"
        );
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function setLimites(uint256 cantidadMinima_, uint256 cantidadMaxima_)
        public
    {
        require(
            owner == msg.sender,
            "Solo el propietario puede cambiar los limites"
        );
        require(
            cantidadMinima_ < cantidadMaxima_,
            "El maximo debe ser mayor que el minimo"
        );
        cantidadMinima = cantidadMinima_; // set minimun amount
        cantidadMaxima = cantidadMaxima_; // set maximum amount
    }
}
