pragma solidity >= 0.4.0;

contract BancoAtacado {

    // mapping que guarda los saldos de los usuarios
    mapping (address => uint) private userBalances;

    // creamos el contrato con 10 ether inicialmente
    constructor() payable {
        require(msg.value >= 10 ether, "Debes inicializar el contrato con al menos 10 ethers");
    }

    // funcion para que los clientes puedan depositar fondos en su cuenta
    function deposit() public payable {
        userBalances[msg.sender] += msg.value;
    }

    // funcion para que los clientes puedan retirar sus fondos
    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        (bool success,  ) = msg.sender.call{value:amountToWithdraw}(""); // At this point, the caller's code is executed, and can call withdrawBalance again
        require(success, "El pago fallo");
        userBalances[msg.sender] = 0;
    }

    // funcion para consultar el saldo
    function miSaldo() public view returns (uint) {
        return address(this).balance;
    }
}