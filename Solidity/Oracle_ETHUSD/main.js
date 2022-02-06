require('dotenv').config();
const Web3 = require('web3');
const fetch = require('node-fetch');
let abi = require("./" + process.env.ABI).abi;
const web3 = new Web3(process.env.WEB3_PROVIDER_ADDRESS);

const address = process.env.CONTRACT_ADDRESS; // IMPORTANTE ACTUALIZAR EL CONTRATO DE ORACULO
const contract = new web3.eth.Contract(abi, address);

/**
 * Obtener una cuenta dada su posicion
 * @param {*} accountNumber 
 */
async function getAccount(accountNumber) {
    const accounts = await web3.eth.getAccounts();
    return accounts[accountNumber];
};

/**
 * Función para enviar una transacción de crear nueva solicitud para obtener precio de ETH.
 * Esta transacción la enviaría el usuario o contrato que necesita obtener la información
 */
async function crearSolicitud() {
    console.log("");
    console.log("Creando nueva solicitud...")
    const account = await getAccount(process.env.ACCOUNT_REQUESTER)
    const receipt = contract.methods.solicitarPrecioETHUSD().send({
        from: account,
        gas: 3500000
    });
}

/**
 * Función para que el oráculo se suscriba a los eventos de nueva solicitud para procesarla
 */
function subscripcionEventoNuevaSolicitud() {
    contract.events.NuevaSolicitud({}, function (error, event) {
        const solicitudId_ = event.returnValues.id_;
        console.log("Nueva Solicitud recibida con id " + solicitudId_)
        fetch('https://api.kraken.com/0/public/Ticker?pair=ETHUSD')
            .then(res => res.json())
            .then(json => {
                debugger
                const precioETHUSD = Math.floor(json.result.XETHZUSD.a[0] * 100);
                console.log("Obtenidos datos del API...");
                enviarRespuesta(solicitudId_, precioETHUSD);
                console.log("Enviando tx con datos de respuesta...");
            });
    });
}

/**
 * Función a la que llama el oráculo una vez obtenido el precio, enviando transacción con el precio obtenido
 */
async function enviarRespuesta(
    id,
    precioETHUSD
) {
    const account = await getAccount(process.env.ACCOUNT_ORACLE)
    const receipt = contract.methods.callbackPrecioETHUSD(id, precioETHUSD).send({
        from: account,
        gas: 3500000
    });
}

/**
 * Función para suscribirse a los eventos de respuesta recibida
 */
function subscripcionEventoNuevaRespuesta() {
    contract.events.NuevaRespuesta({}, function (error, event) {
        console.log("event.returnValues", JSON.stringify(event.returnValues));
        const solicitudId_ = event.returnValues.id_;
        const precioETHUSD = event.returnValues.precioETHUSD_ / 100.0;
        console.log("Respuesta del oraculo para solicitud " + solicitudId_ + ": " + precioETHUSD + " USD/ETH");
    });
}

/**
 * Programa principal:
 * 1. Suscripción a eventos
 * 2. Bucle para crear solicitudes cada 2 segundos
 */
subscripcionEventoNuevaSolicitud();
subscripcionEventoNuevaRespuesta();
setInterval(function () {
    crearSolicitud();
}, 2000);