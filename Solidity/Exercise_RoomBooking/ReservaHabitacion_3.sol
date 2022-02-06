// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";

contract ReservaHabitacion_3 is Ownable{
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

    receive() external payable soloSiDisponible costeExacto(2 ether) {
        estado = Estado.Ocupada;
        emit HabitacionOcupada(msg.sender);
    }

    function setDisponible() external onlyOwner {
        estado = Estado.Disponible;
        emit HabitacionDisponible();
    }

    function widthdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}