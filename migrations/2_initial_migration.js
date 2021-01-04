var BigPurchase = artifacts.require("../contracts/BigPurchase.sol");

module.exports = function(deployer) {
  deployer.deploy(BigPurchase);
};
