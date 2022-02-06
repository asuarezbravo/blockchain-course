// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";

contract ReservaHabitacion_4 is Ownable{

    uint numeroHabitaciones;
    uint habitacionesDisponibles;

    event HabitacionOcupada(address cliente);
    event HabitacionDisponible();

    modifier soloSiDisponible {
        require(habitacionesDisponibles > 0, "Todas las habitaciones ocupadas");
        _;
    }

    modifier costeExacto(uint _amount) {
        require(msg.value == _amount, "Cantidad incorrecta de ether.");
        _;
    }

    constructor(uint numeroHabitaciones_) Ownable(){
        numeroHabitaciones = numeroHabitaciones_;
        habitacionesDisponibles = numeroHabitaciones_;
    }

    receive() external payable soloSiDisponible costeExacto(2 ether) {
        habitacionesDisponibles--;
        emit HabitacionOcupada(msg.sender);
    }

    function setDisponible() external onlyOwner {
        require(habitacionesDisponibles < numeroHabitaciones, "Todas las habitaciones disponibles");
        habitacionesDisponibles++;
        emit HabitacionDisponible();
    }

    function widthdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}