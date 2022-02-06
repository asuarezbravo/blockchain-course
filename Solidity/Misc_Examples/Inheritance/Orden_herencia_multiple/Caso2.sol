// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.4.0;

contract A {
    function append(string a, string b) internal pure returns (string) {
        return string(abi.encodePacked(a, b));
    }

    function print() public pure returns (string) {
        return "A";
    }
}

contract B is A {
    function print() public pure returns (string) {
         return append("B", super.print());
    }
}

contract C is A {
    function print()  public pure returns (string) {
        return append("C", super.print());
    }
}

contract D is B, C {
}