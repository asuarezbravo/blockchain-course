const Crowdsale = artifacts.require("Crowdsale");

module.exports = function(deployer) {
  deployer.deploy(Crowdsale, "My ICO Token", "MIT", 0, 100, 3600, 10);
};
