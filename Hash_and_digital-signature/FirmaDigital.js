const RIPEMD160 = require('ripemd160');
const EC = require('elliptic').ec;
const sha256 = require('js-sha256');

const ec = new EC('secp256k1'); // Bitcoin uses Elliptic Curve Digital Signing Algorithm (ECDSA) to verify transactions

let message = 'Cuerpo_Transaccion'; // This would normally be the transaction hash with amount of money, publicScriptKey
let publicKey = '040c1fbe8b870d636823963ff21ba6e5250571848714203a08ae8700e0d97a1d7bb94ae888af72ac9a4fe02d558599d27c8986398902fa9ac0c1654f5839db1af5';
let privateKey = '2ec6d2808dc7b9d11e49516cfc747435feae8e9872d63c92bc5bde68a894199f';

// hash message - this method hashes the transaction header with SHA256 and then with RIPEMD160
function Hash(msg) {
    let result = sha256(msg);
    return new RIPEMD160().update(msg).digest('hex');
}

function createSignature(message, privateKey) {
    const messageHash = Hash(message);
    const privateKeyPair = ec.keyFromPrivate(privateKey);
    const signature = ec.sign(messageHash, privateKeyPair); // generate a signature on the hashed message with the private key
    console.log('> Mensaje: ', message);
    console.log('> Clave privada: ', privateKey);
    console.log('> Firma digital: ', signature.toDER('hex'));
    return signature;
}

function verifySignature(message, publicAddress, signature) {
    const messageHash = Hash(message);
    const publicKeyPair = ec.keyFromPublic(publicAddress, 'hex'); // use the accessible public key to verify the signature
    const isVerified = publicKeyPair.verify(messageHash, signature);
    console.log('> Mensaje: ', message);
    console.log('> Clave publica: ', publicAddress);
    console.log('> Firma digital: ', signature.toDER('hex'));
    console.log('> ¿Es válida?: ', isVerified?'SI':'NO');
    return isVerified;
}

function testVerification(publicKey, privateKey, message, messageVerify) {
    console.log('Creación de firma digital:');
    const signature = createSignature(message, privateKey);
    console.log('\nVerificación de firma digital:');
    const isVerified = verifySignature(messageVerify, publicKey, signature);
}

console.log("-------EJEMPLO DE FIRMA VÁLIDA:---------")
testVerification(publicKey, privateKey, message, message); // true

console.log("\n")
console.log("-------EJEMPLO DE FIRMA INVÁLIDA POR CLAVE PUBLICA INCORRECTA:---------")
let wrongPublicKey = '04487bd002b2b61a1bbc89b3c05cebf73039d4722c96877308ee4905c10f155d71f03dca22650a2aea193416dd5071260b3fca82ab5a254163371e5929fb28c0f2';
testVerification(wrongPublicKey, privateKey, message, message); // false

console.log("\n")
console.log("-------EJEMPLO DE FIRMA INVÁLIDA POR MENSAJE INCORRECTO---------")
testVerification(publicKey, privateKey, message, "Cuertpo_Distinto"); // false