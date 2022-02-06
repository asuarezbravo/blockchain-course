pragma solidity ^0.8.3;

contract Emision {

    string public nombre;
    uint public nominal;
    uint public interes; // con dos decimales. 4% sería 400.
    uint[2] public distribucion = [25, 75]; // tiene que sumar 100%. Datos de ejemplo
    uint[2] public cantidadesPagadas = [0, 0];

    address contratoLogica;

    constructor(string memory _nombre, uint _nominal, uint _interes, address _contratoLogica) {
        nombre = _nombre;
        nominal = _nominal;
        interes = _interes;
        contratoLogica = _contratoLogica;
    }

    function pagoInteres() public {
        contratoLogica.delegatecall(abi.encodeWithSignature("pagaInteres()"));
    }
}

contract LogicaEmisiones {

    string public nombre;
    uint public nominal;
    uint public interes; // con dos decimales
    uint[2] public distribucion = [25, 75];
    uint[2] public cantidadesPagadas = [0, 0];

    function pagaInteres() public {
        for(uint i = 0; i < distribucion.length; i++) {
            cantidadesPagadas[i] = nominal * interes / 10000 * distribucion[i] / 100; // nominal x interes x saldo
        }
    }
}