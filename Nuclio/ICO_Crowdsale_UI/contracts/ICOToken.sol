// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8;

import "./ERC/ERC20.sol";
import "./Crowdsale.sol";

contract ICOToken is ERC20 {
    address public crowdsaleAddress;
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier afterCrowdsale() {
        require(
            Crowdsale(payable(crowdsaleAddress)).isCompleted() ||
                msg.sender == crowdsaleAddress
        );
        _;
    }

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _supply,
        address _crowdsaleAddress
    ) ERC20(_name, _symbol, _decimals) {
        require(_crowdsaleAddress != address(0));
        require(_supply > 0);
        _mint(_crowdsaleAddress, _supply);
        owner = msg.sender;
        crowdsaleAddress = _crowdsaleAddress;
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function transfer(address _to, uint256 _value)
        public
        virtual
        override
        afterCrowdsale
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public virtual override afterCrowdsale returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    /// @notice Override the functions to not allow token transfers until the end of the ICO
    function approve(address _spender, uint256 _value)
        public
        virtual
        override
        afterCrowdsale
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    function emergencyExtract() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
