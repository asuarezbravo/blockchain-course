// SPDX-License-Identifier: GPL-3.0

pragma solidity ^ 0.8 .0;

import "./MIAX.sol";
import "./Ownable.sol";

contract DEX is Ownable {


    MiToken contratoMiToken;
    bool pausado;

    event MercadoAbierto(uint256 timestamp_);

    constructor(address direccionMiToken_) Ownable() {
        contratoMiToken = MiToken(direccionMiToken_);
    }

    function proveerLiquidez() public payable {
        require(msg.value > 0, "Debes proveer ETH");
        require(contratoMiToken.allowance(address(this)) > 0, "Debes proveer MiToken");
        contratoMiToken.transferFrom(msg.sender, address(this), contratoMiToken.allowance(address(this)));
        emit MercadoAbierto(block.timestamp);
    }

    function comprarMiax() public payable {
        uint precio = precioCompraMiToken();
        contratoMiToken.transfer(address(this), precio * msg.value);
    }

    function comprarETH(uint cantidad_) public {
        uint precio = precioCompraEth();
        contratoMiToken.transferFrom(msg.sender, address(this), cantidad_);
        payable(msg.sender).transfer(precio * cantidad_);
    }

    function precioCompraMiToken() public view returns(uint precio_) {
        precio_ = address(this).balance / contratoMiToken.balanceOf(address(this));
    }

    function precioCompraEth() public view returns(uint precio_) {
        precio_ = contratoMiToken.balanceOf(address(this)) / address(this).balance;
    }

    function constanteK() public view returns(uint) {
        return contratoMiToken.balanceOf(address(this)) * address(this).balance;
    }

}