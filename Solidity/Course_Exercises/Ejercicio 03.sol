// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.4;

contract Vehiculo {

    enum TipoVehiculo {
        TURIMO,
        CAMION,
        AUTOBUS
    }

    uint8 public numPuertas;
    bool public esGasolina;
    address private propietario;
    TipoVehiculo public tipo;
    string public matricula;
    string public modelo;
    address[] private asegurados;
}

contract RegistroVehiculos {
    mapping(string => Vehiculo) registro;
}