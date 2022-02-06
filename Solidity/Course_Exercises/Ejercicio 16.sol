pragma solidity ^0.5.0;

contract Test {

    uint valor;

    function sumaSolidity(uint a, uint b) public {
        valor = a + b;
    }

    function sumaAssembly(uint a, uint b) public {
        assembly {
            mstore(add(a, b), valor_slot)
        }
    }
}