// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";

contract Banco is Ownable{

    uint public numClientes;
    uint comisiones;

    struct Cliente {
        bool existe;
        uint saldo;
    }
    mapping(address => Cliente) clientes;
    mapping(address => bool) blacklist;

    event NuevoCliente(address direccion, uint numCLientes);
    event NuevoDeposito(address direccion, uint cantidad);
    event NuevaRetirada(address direccion, uint cantidad);

    modifier esCliente(bool existe) {
        require(clientes[msg.sender].existe == existe, "Direccion ya registrada");
        _;
    }

    modifier enBlacklist(bool enLista) {
        require(blacklist[msg.sender] == enLista, "En blacklist");
        _;
    }

    constructor() Ownable() payable {
        require(msg.value == 3 ether, "No has hecho el prefondeo");
    }

    function registrarse() public esCliente(false) enBlacklist(false) {
        clientes[msg.sender] = Cliente(true, numClientes < 3 ? 1 ether : 0 ether);
        numClientes++;
        emit NuevoCliente(msg.sender, numClientes);
    }

    function miSaldo() public esCliente(true) enBlacklist(false) view returns(uint) {
        return clientes[msg.sender].saldo;
    }

    function depositar() public esCliente(true) enBlacklist(false) payable {
        require(msg.value >= 100, "Enviame al menos 100 wei");
        clientes[msg.sender].saldo += msg.value;
        emit NuevoDeposito(msg.sender, msg.value);
    }

    function retirar(uint cantidad) public esCliente(true) enBlacklist(false) {
        require(cantidad >= 100, "Enviame al menos 100 wei");
        require(clientes[msg.sender].saldo >= cantidad, "No tienes saldo suficiente");
        uint cantidadAEnviar = cantidad / 100 * 99;
        payable(msg.sender).transfer(cantidadAEnviar);
        clientes[msg.sender].saldo -= cantidad;
        emit NuevaRetirada(msg.sender, cantidad);
        comisiones += cantidad - cantidadAEnviar;
    }

    function bloquear(address direccion) public onlyOwner {
        blacklist[direccion] = true;
    }

    function desbloquear(address direccion) public onlyOwner {
        blacklist[direccion] = false;
    }

    function retirarComisiones() public onlyOwner {
        payable(owner).transfer(comisiones);
        comisiones = 0;
    }

    function saldoContrato() public onlyOwner  view returns (uint) {
        return address(this).balance;
    }
}