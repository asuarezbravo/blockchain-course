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
    string public matricula;
    address private propietario;
    TipoVehiculo public tipo;
    string public modelo;
    address[] private asegurados;

    constructor(uint8 numPuertas_, bool esGasolina_, string memory matricula_, address propietario_, TipoVehiculo tipo_, string memory modelo_) {
        require(propietario_ != address(0), "El propietario es invalido"); // 0x0000000000000000000000000000000000000000 
        require(bytes(matricula_).length > 0, "La matricula es invalida");
        require(numPuertas_ > 1, "El numero de puertas debe ser mayor que 0");

        numPuertas = numPuertas_;
        esGasolina = esGasolina_;
        matricula = matricula_;
        propietario = propietario_;
        tipo = tipo_;
        modelo = modelo_;
        asegurados.push(propietario_);
    }

    function anadirAsegurado(address nuevoAsegurado_) public {
        require(nuevoAsegurado_ != address(0), "El asegurado es invalido");
        asegurados.push(nuevoAsegurado_);
    }

    function getPropietario() public view returns(address propietario_) {
        return (propietario);
    }

    function getCombustible() public view returns (string memory combustible_) {
        if (esGasolina) {
            combustible_ = "GASOLINA";
        } else {
            return "DIESEL";
        }
    }
}

contract RegistroVehiculos {
    struct EntradaRegistro {
        bool existe;
        Vehiculo vehiculo;
    }

    address public propietario;
    mapping(string => EntradaRegistro) public registro;
    uint256 public numVehiculos;

    event VehiculoRegistrado(string matricula_, address vehiculo_, uint256 numVehiculos_);

    constructor() {
        propietario = msg.sender;
    }

    modifier soloPropietario() {
        require(msg.sender == propietario, "Solo el propietario puede hacer esto");
        _;
    }

    function anadirVehiculo(Vehiculo vehiculo_) public soloPropietario payable {
        require(address(vehiculo_) != address(0), "El vehiculo es invalido");
        require(!registro[vehiculo_.matricula()].existe, "El vehiculo ya ha sido registrado");

        registro[vehiculo_.matricula()] = EntradaRegistro(true, vehiculo_);
        numVehiculos++;
        emit VehiculoRegistrado(vehiculo_.matricula(), address(vehiculo_), numVehiculos);
    }

    function getVehiculo(string memory matricula_) public view returns(Vehiculo _vehiculo) {
        return registro[matricula_].vehiculo;
    }
}