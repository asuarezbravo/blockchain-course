const ERC20Limites_4 = artifacts.require("ERC20Limites_4");

module.exports = function(deployer) {
  deployer.deploy(ERC20Limites_4, "Mi Token", "MT", 0, 1000, 10, 50)
};
