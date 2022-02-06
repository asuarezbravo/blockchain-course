const Banco = artifacts.require("Banco");
const RegistroTrafico = artifacts.require("RegistroTrafico");
const VehiculoMetadata = artifacts.require("VehiculoMetadata");
const Concesionario = artifacts.require("Concesionario");

contract("Tests", async accounts => {
    const banco = accounts[0];
    const trafico = accounts[1];
    const concesionario = accounts[2];
    const vendedor = accounts[3];
    const comprador = accounts[4];

    const precioCoche = 1000000; // 10.000,00 euros

    const numPuertas = 5;
    const esGasolina = true;
    const matricula = web3.utils.utf8ToHex("2345LPR");
    const tipo = 0;
    const modelo = "Peugeot 207";

    it("Test deposito efectivo en cuenta comprador", async () => {
        let instanceBanco = await Banco.deployed();
        //comprobamos que en el momento inicial el comprador no tiene dinero
        let balance = await instanceBanco.balanceOf.call(comprador);
        assert.equal(balance.valueOf(), 0);
        //se le hace un deposito por el precio del vehiculo
        await instanceBanco.depositar(comprador, precioCoche, {
            from: banco
        })
        //se comprueba el nuevo saldo
        balance = await instanceBanco.balanceOf.call(comprador);
        assert.equal(balance.valueOf(), precioCoche);
    });

    it("Test registro de coche a nombre de vendedor", async () => {
        let instanceRegistroTrafico = await RegistroTrafico.deployed();
        //comprobamos que la matricula no existe en el registro
        let existeMatricula = await instanceRegistroTrafico.existeMatricula.call(matricula);
        assert.equal(existeMatricula, false);
        //registramos el nuevo vehiculo
        await instanceRegistroTrafico.registrarNuevoVehiculo(vendedor, numPuertas, esGasolina, matricula, tipo, modelo, {
            from: trafico
        })
        //comprobamos que se ha registrado correctamente
        existeMatricula = await instanceRegistroTrafico.existeMatricula.call(matricula);
        assert.equal(existeMatricula, true);
    });

    it("Test publicación anuncio venta", async () => {
        let instanceConcesionario = await Concesionario.deployed();
        let instanceRegistroTrafico = await RegistroTrafico.deployed();

        //comprobamos que no existe anuncio para el vehiculo
        let existeAnuncioVehiculo = await instanceConcesionario.existeAnuncioVehiculo.call(matricula);
        assert.equal(existeAnuncioVehiculo, false);
        //damos permiso al contrato del concesionario para cambiar registro
        await instanceRegistroTrafico.approve(instanceConcesionario.address, matricula, {
            from: vendedor
        })
        //y publicamos anuncio
        await instanceConcesionario.publicarAnuncioVenta(matricula, precioCoche, {
            from: vendedor
        })
        //comprobamos que el anuncio ahora ya existe
        existeAnuncioVehiculo = await instanceConcesionario.existeAnuncioVehiculo.call(matricula);
        assert.equal(existeAnuncioVehiculo, true);
    });

    it("Test compra anuncio venta", async () => {
        let instanceConcesionario = await Concesionario.deployed();
        let instanceBanco = await Banco.deployed();
        let instanceRegistroTrafico = await RegistroTrafico.deployed();
        //comprobamos que el anuncio existe
        let existeAnuncioVehiculo = await instanceConcesionario.existeAnuncioVehiculo.call(matricula);
        assert.equal(existeAnuncioVehiculo, true);
        //damos permiso al contrato del concesionario para cargar la cantidad 
        await instanceBanco.increaseAllowance(instanceConcesionario.address, precioCoche, {
            from: comprador
        })
        //y compramos el vehiculo
        await instanceConcesionario.comprarAnuncio(matricula, {
            from: comprador
        })
        //comprobamos que el anuncio se ha borrado
        existeAnuncioVehiculo = await instanceConcesionario.existeAnuncioVehiculo.call(matricula);
        assert.equal(existeAnuncioVehiculo, false);
        //comprobamos que el propietario del vehiculo ha cambiado
        const vehiculosComprador = await instanceRegistroTrafico.getListaVehiculosPropietario.call(comprador);
        assert.equal(vehiculosComprador.length, 1);
        //comprobamos que el saldo de efectivo a pasado del comprador al vendedor
        let balance = await instanceBanco.balanceOf.call(vendedor);
        assert.equal(balance.valueOf(), precioCoche);
        balance = await instanceBanco.balanceOf.call(comprador);
        assert.equal(balance.valueOf(), 0);
    });

});