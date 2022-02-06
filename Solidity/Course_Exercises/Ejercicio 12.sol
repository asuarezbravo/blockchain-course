// // SPDX-License-Identifier: GPL-3.0

// pragma solidity >=0.4.22 <0.9.0;

// // This import is automatically injected by Remix
// import "remix_tests.sol";

// // This import is required to use custom transaction context
// // Although it may fail compilation in 'Solidity Compiler' plugin
// // But it will work fine in 'Solidity Unit Testing' plugin
// import "remix_accounts.sol";
// import "../contracts/1_Storage.sol";

// contract MyTest {
//     Storage st;

//     // beforeEach works before running each test
//     function beforeEach() public {
//         st = new Storage();
//     }

//     /// Test if initial value is set correctly
//     function checkInitial() public returns (bool) {
//         return Assert.equal(st.retrieve(), 0, "initial value is not correct");
//     }

//     /// Test if value is set as expected
//     function valueIsSet100() public returns (bool) {
//         st.store(100);
//         return Assert.equal(st.retrieve(), 100, "value is not 100");
//     }
// }

pragma solidity >=0.4.22 <0.9.0;

// This import is automatically injected by Remix
import "remix_tests.sol";

// This import is required to use custom transaction context
// Although it may fail compilation in 'Solidity Compiler' plugin
// But it will work fine in 'Solidity Unit Testing' plugin
import "remix_accounts.sol";
import "../contracts/Calculadora.sol";

// File name has to end with '_test.sol', this file can contain more than one testSuite contracts
contract myTest {
    Calculadora prueba;

    function beforeAll() public {
        prueba = new Calculadora();
    }

    function testSuma() public {
        Assert.equal(prueba.suma(1, 2), 3, "No suma bien");
    }
}
