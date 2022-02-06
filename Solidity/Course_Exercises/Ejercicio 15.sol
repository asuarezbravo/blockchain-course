pragma solidity ^0.5.0;

library MathLib {

    function suma(uint a, uint b) public view returns (uint, address) {
        require(a + b > a, "Overflow");
        return (a + b, address(this));
    }

    function resta(uint a, uint b) public view returns (uint, address) {
        require(a - b < a, "Underflow");
        return (a - b, address(this));
    }
}


contract MiContrato {

    using MathLib for uint;

    address owner = address(this);

    uint public valor;

    function incrementa(uint _newVal) public returns (uint, address) { //como vemos, address devuelve la dirección de MiContrato, no la de la librería al ejecutarse en su contexto
        (uint val, address addr) = valor.suma(_newVal);
        valor = val;
        return (val, addr);
    }
    function decrementa(uint _newVal) public returns (uint, address) {
        (uint val, address addr) = valor.resta(_newVal);
        valor = val;
        return (valor, addr);
    }
}