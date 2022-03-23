const ERC20Limites = artifacts.require("ERC20Limites");

module.exports = function(deployer) {
  deployer.deploy(ERC20Limites, "Mi Token", "MT", 0, 1000, 10, 50)
};
