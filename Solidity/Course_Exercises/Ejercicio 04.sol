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

    constructor(uint8 numPuertas_, bool esGasolina_, address propietario_, TipoVehiculo tipo_, string memory matricula_, string memory modelo_) {
        numPuertas = numPuertas_;
        esGasolina = esGasolina_;
        matricula = matricula_;
        propietario = propietario_;
        tipo = tipo_;
        modelo = modelo_;
        asegurados.push(propietario_);
    }

    function anadirAsegurado(address nuevoAsegurado_) public {
        asegurados.push(nuevoAsegurado_);
    }

    function getPropietario() public view returns(address propietario_) {
        return (propietario);
    }
}

contract RegistroVehiculos {
    mapping(string => Vehiculo) registro;
}