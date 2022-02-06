const Banco = artifacts.require("Banco");
const RegistroTrafico = artifacts.require("RegistroTrafico");
const Concesionario = artifacts.require("Concesionario");

module.exports = async (deployer, network, accounts) => {
  const banco = accounts[0];
  const trafico = accounts[1];
  const concesionario = accounts[2];

  await deployer.deploy(Banco, {
    from: banco
  });
  await deployer.deploy(RegistroTrafico, {
    from: trafico
  });
  await deployer.deploy(Concesionario, Banco.address, RegistroTrafico.address, {
    from: concesionario
  });
};