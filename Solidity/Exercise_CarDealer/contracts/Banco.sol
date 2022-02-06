// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "./ERC/ERC20.sol";
import "./Utils/Ownable.sol";

/**
* @dev Contrato para nuestro modulo Banco implementado con estandar ERC20 de tokens fungibles.
*/
contract Banco is ERC20, Ownable {

    /**
    * @dev Constructor por defecto que inicializa el nombre, simbolo y decimales
    */
    constructor() ERC20("Euro tokenizado", "EUR", 2) {
    }

    /**
     * @dev Funcion para depositar euros en una cuenta. Solo el dueño puede realizar esta acción.
     */
    function depositar(address account_, uint256 amount_) public onlyOwner {
        _mint(account_, amount_);
    }

    /**
     * @dev Funcion para retirar euros de una cuenta. Solo el dueño puede realizar esta acción.
     */
    function retirar(address account_, uint256 amount_) public onlyOwner {
        _burn(account_, amount_);
    }
}