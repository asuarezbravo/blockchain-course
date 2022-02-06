// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";

contract ReservaHabitacion is Ownable{
    enum Estado { Disponible, Ocupada }

    Estado public estado;

    event HabitacionOcupada(address cliente);
    event HabitacionDisponible();

    modifier soloSiDisponible {
        require(estado == Estado.Disponible, "Habitacion ocupada.");
        _;
    }

    modifier costeExacto(uint _amount) {
        require(msg.value == _amount, "Cantidad incorrecta de ether.");
        _;
    }

    constructor() Ownable(){
        estado = Estado.Disponible;
    }

    function reservar() external payable soloSiDisponible costeExacto(2 ether) {
        estado = Estado.Ocupada;
        payable(owner).transfer(msg.value);
        emit HabitacionOcupada(msg.sender);
    }

    function setDisponible() external onlyOwner {
        estado = Estado.Disponible;
        emit HabitacionDisponible();
    }
}