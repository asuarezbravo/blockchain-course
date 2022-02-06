const Oraculo = artifacts.require("Oraculo");

module.exports = function(deployer) {
  deployer.deploy(Oraculo);
};
