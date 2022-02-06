// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4;

import "./Ownable.sol";
import "./ERC/ERC20.sol";

contract ERC20Minimo is ERC20, Ownable{

    uint256 public cantidadMinima;

    constructor(uint256 cantidadMinima_, uint256 supply_, string memory name_, string memory symbol_, uint8 decimals_) Ownable() ERC20(name_, symbol_, decimals_){
        cantidadMinima = cantidadMinima_;
        _mint(msg.sender, supply_);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        require(amount >= cantidadMinima, "La cantidad debe ser mayor o igual que el minimo");
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function setCantidadMinima(uint256 cantidadMinima_) public onlyOwner {
        cantidadMinima = cantidadMinima_;
    }
}