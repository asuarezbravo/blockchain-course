// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

// This is a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract Oraculo {
    event NuevaSolicitud(uint256 indexed id_, address remitente_);
    event NuevaRespuesta(uint256 indexed id_, uint256 precioETHUSD_);

    struct Solicitud {
        uint256 id;
        address remitente;
        bool procesada;
        bool existe;
    }

    uint256 id;
    mapping(uint256 => Solicitud) solicitudes;

    constructor() public {
        id = 0;
    }

    function solicitarPrecioETHUSD() public returns (uint256 id_){
        id++;
        Solicitud memory solicitud = Solicitud({
            id: id,
            remitente: msg.sender,
            procesada: false,
            existe: true
        });
        solicitudes[id] = solicitud;
        emit NuevaSolicitud (id, msg.sender);
        return (id);
    }

    function callbackPrecioETHUSD(uint256 idSolicitud_, uint256 precioETHUSD_) public {
        Solicitud storage solicitud = solicitudes[idSolicitud_];
        require(solicitud.existe, "La solicitud no existe");
        require(!solicitud.procesada, "La solicitud ya fue procesada");
        solicitud.procesada = true;
        emit NuevaRespuesta(idSolicitud_, precioETHUSD_);
    }
}
