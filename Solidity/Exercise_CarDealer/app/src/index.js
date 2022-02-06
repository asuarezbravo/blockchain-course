import Web3 from "web3";
import bancoArtifact from "../../build/contracts/Banco.json";
import registroTraficoArtifact from "../../build/contracts/RegistroTrafico.json";
import concesionarioArtifact from "../../build/contracts/Concesionario.json";
import vehiculoMetadataArtifact from "../../build/contracts/VehiculoMetadata.json";

const App = {
  web3: null,
  account: null,
  meta: null,
  banco: null,
  trafico: null,
  concesionario: null,
  misVehiculos: [],

  start: async function () {
    const {
      web3
    } = this;

    try {
      // get contract instance
      const networkId = await web3.eth.net.getId();
      this.banco = new web3.eth.Contract(
        bancoArtifact.abi,
        bancoArtifact.networks[networkId].address,
      );
      this.trafico = new web3.eth.Contract(
        registroTraficoArtifact.abi,
        registroTraficoArtifact.networks[networkId].address,
      );
      this.concesionario = new web3.eth.Contract(
        concesionarioArtifact.abi,
        concesionarioArtifact.networks[networkId].address,
      );

      // get accounts
      const accounts = await web3.eth.getAccounts();
      this.account = accounts[0];

      await this.actualizarCuenta();
      await this.updateBancoAdmin();
      await this.bancoObtenerSaldo();
      await this.updateTraficoAdmin();
      await this.traficoObtenerVehiculos();
      await this.concesionarioObtenerAnunciosActivos();

      document.getElementsByClassName("banco-contract-address")[0].innerHTML = this.banco._address;
      document.getElementsByClassName("trafico-contract-address")[0].innerHTML = this.trafico._address;
      document.getElementsByClassName("concesionario-contract-address")[0].innerHTML = this.concesionario._address;

      window.ethereum.on('accountsChanged', function (accounts) {
        location.reload();
      })

    } catch (error) {
      console.error("Could not connect to contract or chain.");
    }
  },
  setStatus: function (message) {
    const status = document.getElementById("status");
    status.innerHTML = message;
  },
  actualizarCuenta: async function () {
    const cuenta = document.getElementsByClassName("cuenta")[0];
    cuenta.innerHTML = this.account;

    const role = document.getElementsByClassName("role")[0];
    switch (this.account) {
      case '0x6F6ffeF94F8425b55A8cB22fd1d94f05A2B275a5':
        role.innerHTML = "Admin Banco";
        break;
      case '0x7A5D4bf64AA20EB227c07921d07F3e49975f1caf':
        role.innerHTML = "Admin Registro Tráfico";
        break;
      case '0x7f0d231a3cD11BA6b017515636338ceba1Fea393':
        role.innerHTML = "Admin Concesionario";
        break;
      case '0x57B5b7fe3Ae6856D454dbBCaFE1fb6A409Dd83Eb':
        role.innerHTML = "Usuario Vendedor";
        break;
      case '0x26A264F58E5eC0fDE0a1BEA4f5C34a52786E3781':
        role.innerHTML = "Usuario Comprador";
        break;
    }
  },
  isBancoAdmin: async function () {
    const {
      owner
    } = this.banco.methods;
    const addrOwner = await owner().call();
    const isOwner = addrOwner === this.account;
    return isOwner;
  },
  updateBancoAdmin: async function () {
    const isOwner = await this.isBancoAdmin();
    if (!isOwner) {
      const bancoAdmin = document.getElementById("banco-admin");
      bancoAdmin.style.display = "none";
    }
  },
  bancoObtenerSaldo: async function () {
    const {
      balanceOf,
      totalSupply
    } = this.banco.methods;
    const balanceUser = await balanceOf(this.account).call();
    const balanceTotal = await totalSupply().call();

    const balanceUserElement = document.getElementsByClassName("banco-balance-user")[0];
    balanceUserElement.innerHTML = balanceUser;

    const balanceTotalElement = document.getElementsByClassName("banco-balance-total")[0];
    balanceTotalElement.innerHTML = balanceTotal;
  },
  bancoDeposito: async function () {
    const cantidad = parseInt(document.getElementById("banco-deposito-cantidad").value);
    const destinatario = document.getElementById("banco-deposito-destinatario").value;

    this.setStatus("Iniciando transacción...(espere)");

    const {
      depositar
    } = this.banco.methods;
    await depositar(destinatario, cantidad).send({
      from: this.account
    });

    this.setStatus("Transacción completada");
    this.bancoObtenerSaldo();
  },
  bancoRetirada: async function () {
    const cantidad = parseInt(document.getElementById("banco-retirada-cantidad").value);
    const destinatario = document.getElementById("banco-retirada-destinatario").value;

    this.setStatus("Iniciando transacción...(espere)");

    const {
      retirar
    } = this.banco.methods;
    await retirar(destinatario, cantidad).send({
      from: this.account
    });

    this.setStatus("Transacción completada");
    this.bancoObtenerSaldo();
  },
  isTraficAdmin: async function () {
    const {
      owner
    } = this.trafico.methods;
    const addrOwner = await owner().call();
    const isOwner = addrOwner === this.account;
    return isOwner;
  },
  updateTraficoAdmin: async function () {
    const isOwner = await this.isTraficAdmin();
    if (!isOwner) {
      const traficoAdmin = document.getElementById("trafico-admin");
      traficoAdmin.style.display = "none";
    }
  },
  traficoObtenerVehiculos: async function () {
    const {
      web3
    } = this;

    const {
      getListaVehiculosPropietario,
      getListaVehiculos
    } = this.trafico.methods;
    this.misVehiculos = await getListaVehiculosPropietario(this.account).call();
    let text = '<ul>';
    for (let i = 0; i < this.misVehiculos.length; i++) {
      const vehiculo = await this.getVehiculoMetadataByAddress(this.misVehiculos[i]);
      text += '<li>' + web3.utils.hexToUtf8(vehiculo.matricula_) + '</li>';
    }
    text += '</ul>'
    if (this.misVehiculos.length === 0) text = 'No tiene vehículos registrados a su nombre';
    const vehiculosElement = document.getElementsByClassName("trafico-vehiculos-user")[0];
    vehiculosElement.innerHTML = text;

    const isOwner = await this.isTraficAdmin();
    if (isOwner) {
      const todosVehiculos = await getListaVehiculos().call();
      let text = '';
      for (let i = 0; i < todosVehiculos.length; i++) {
        const vehiculo = await this.getVehiculoMetadataByAddress(todosVehiculos[i]);
        text += '<li>Matrícula: ' + web3.utils.hexToUtf8(vehiculo.matricula_) + ', Propietario: ' + todosVehiculos[2][i] + '</li>';
      }
      if (todosVehiculos.length === 0) text = 'No hay vehículos registrados';
      const todosVehiculosElement = document.getElementsByClassName("trafico-vehiculos-admin")[0];
      todosVehiculosElement.innerHTML = text;
    }
  },
  traficoRegistroNuevoVehiculo: async function () {
    const {
      web3
    } = this;

    const numPuertas = parseInt(document.getElementById("trafico-registro-puertas").value);
    const esGasolina = document.getElementById("trafico-registro-gasolina").value == 'true';
    const tipo = parseInt(document.getElementById("trafico-registro-tipo").value);
    const modelo = document.getElementById("trafico-registro-modelo").value;
    const matricula = web3.utils.utf8ToHex(document.getElementById("trafico-registro-matricula").value);

    this.setStatus("Iniciando transacción...(espere)");
    const {
      registrarNuevoVehiculo
    } = this.trafico.methods;
    const propietario = document.getElementById("trafico-registro-propietario").value;
    await registrarNuevoVehiculo(propietario, numPuertas, esGasolina, matricula, tipo, modelo).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    this.traficoObtenerVehiculos();
  },
  getVehiculoMetadataByAddress: async function (address) {
    const {
      web3
    } = this;
    const contract = new web3.eth.Contract(
      vehiculoMetadataArtifact.abi,
      address,
    );
    const {
      getInfo
    } = contract.methods;
    const info = await getInfo().call();
    return info;
  },
  concesionarioObtenerAnunciosActivos: async function () {
    const {
      web3
    } = this;
    const {
      getListaVehiculosConAnuncio,
      getAnuncio
    } = this.concesionario.methods;
    let anuncios = await getListaVehiculosConAnuncio().call();
    anuncios = anuncios.filter(function (item, pos, self) {
      return self.indexOf(item) == pos;
    })
    let text = '';
    let count = 0;
    for (let i = 0; i < anuncios.length; i++) {
      const anuncio = await getAnuncio(anuncios[i]).call();
      if (anuncio.existe_) {
        text += '<br>' + 'Id: ' + anuncio.id_ + ', Matricula: ' + web3.utils.hexToUtf8(anuncio.matricula_) + ', Precio (en céntimos): ' + anuncio.precioVenta_.valueOf();
        if (anuncio.propietario_ === this.account)
          text += '<a style="margin-left: 15px" href="javascript:App.concesionarioEliminarAnuncioVehiculo(\'' + anuncio.matricula_ + '\')">Eliminar</a>';
        else
          text += '<a style="margin-left: 15px" href="javascript:App.concesionarioComprarAnuncioVehiculo(\'' + anuncio.matricula_ + '\',' + anuncio.precioVenta_ + ')">Comprar</a>';
        count++;
      }
    }
    if (count === 0) text = 'No hay anuncios de venta activos';
    const anunciosElement = document.getElementsByClassName("concesionario-anuncios")[0];
    anunciosElement.innerHTML = text;
  },
  concesionarioPublicarAnuncioVehiculo: async function () {
    const {
      web3
    } = this;
    const precio = parseInt(document.getElementById("concesionario-publicar-precio").value);
    const matricula = web3.utils.utf8ToHex(document.getElementById("concesionario-publicar-matricula").value);
    debugger
    this.setStatus("Iniciando transacción...(espere)");
    const {
      approve
    } = this.trafico.methods;
    await approve(this.concesionario._address, matricula).send({
      from: this.account
    })
    const {
      publicarAnuncioVenta
    } = this.concesionario.methods;
    await publicarAnuncioVenta(matricula, precio).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    this.concesionarioObtenerAnunciosActivos();
  },
  concesionarioComprarAnuncioVehiculo: async function (matricula, precio) {
    this.setStatus("Iniciando transacción...(espere)");
    const {
      approve
    } = this.banco.methods;
    await approve(this.concesionario._address, precio).send({
      from: this.account
    })
    const {
      comprarAnuncio
    } = this.concesionario.methods;
    await comprarAnuncio(matricula).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    await this.bancoObtenerSaldo();
    await this.traficoObtenerVehiculos();
    await this.concesionarioObtenerAnunciosActivos();
  },
  concesionarioEliminarAnuncioVehiculo: async function (matricula, precio) {
    this.setStatus("Iniciando transacción...(espere)");
    const {
      cancelarAnuncioVenta
    } = this.concesionario.methods;
    await cancelarAnuncioVenta(matricula).send({
      from: this.account
    })
    this.setStatus("Transacción completada");
    await this.concesionarioObtenerAnunciosActivos();
  }
};

window.App = App;

window.addEventListener("load", function () {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum);
    window.ethereum.enable(); // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:7545. You should remove this fallback when you deploy live",
    );
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    );
  }

  App.start();
});