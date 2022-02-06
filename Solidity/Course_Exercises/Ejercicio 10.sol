// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.6;

contract Ownable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario puede hacer esto");
        _;
    }
}

contract Vehiculo is Ownable {

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

    function anadirAsegurado(address nuevoAsegurado_) public onlyOwner {
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

contract RegistroVehiculos is Ownable {
    mapping(string => Vehiculo) public registro;
    uint256 public numVehiculos;

    event VehiculoRegistrado(string matricula_, address vehiculo_, uint256 numVehiculos_);

    constructor() Ownable() {}

    function anadirVehiculo(Vehiculo vehiculo_) public onlyOwner payable {
        require(address(vehiculo_) != address(0), "El vehiculo es invalido");
        require(address(registro[vehiculo_.matricula()]) == address(0), "El vehiculo ya ha sido registrado");

        registro[vehiculo_.matricula()] = vehiculo_;
        numVehiculos++;
        emit VehiculoRegistrado(vehiculo_.matricula(), address(vehiculo_), numVehiculos);
    }

    function getVehiculo(string memory matricula_) public view returns(Vehiculo _vehiculo) {
        return registro[matricula_];
    }
}