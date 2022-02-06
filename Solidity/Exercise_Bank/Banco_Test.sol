// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "remix_accounts.sol";
import "../contracts/Banco.sol";

contract BancoTest {


    Banco bancoTest;
    /// #value: 5000000000000000000
    function beforeAll () public payable {
        bancoTest = (new Banco){value: 3 ether}();
    }

    function testComprobarPropietario() public {
        Assert.equal(address(this), bancoTest.owner(), 'El propietario deberia ser la cuenta 0');
    }

    function testRegistrar () public {
        Assert.equal(bancoTest.numClientes(), uint(0), "El numero de clientes deberia ser 0");
        bancoTest.registrarse();
        Assert.equal(bancoTest.numClientes(), uint(1), "El numero de clientes deberia ser 1");
    }

    /// #sender: account-1
    /// #value: 1000000000000000000
    function testDepositar() public {
        Assert.equal(bancoTest.saldo(), uint(1000000000000000000), "El saldo deberia ser 1 ethers");
        bancoTest.depositar{value: 1 ether}();
        Assert.equal(bancoTest.saldo(), uint(2000000000000000000), "El saldo deberia ser 2 ethers");
    }

    /// #sender: account-1
    function testRetirar() public {
        Assert.equal(bancoTest.saldo(), uint(2000000000000000000), "El saldo deberia ser 2 ethers");
        bancoTest.retirar(2000000000000000000);
        Assert.equal(bancoTest.saldo(), uint(0), "El saldo deberia ser 0 ethers");
    }

    function testSaldoContrato() public {
        Assert.equal(bancoTest.saldoContrato(), uint(2000000000000000000)+uint(2000000000000000000/100), "El saldo deberia ser 2 ethers iniciales + 1% comision retirada");     
    }

    // funcion receive necesaria para recibir los fondos al hacer una retirada
    receive() external payable{

    }
}
