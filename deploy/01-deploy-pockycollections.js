const { network } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log('----------------------------------------------------');
  const deployResult = await deploy('PockyCollections', {
    from: deployer,
    args: [],
    waitConfirmations: 1,
  });
  if (deployResult.newlyDeployed) {
    log(`contract PockyCollections deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
  }
};
module.exports.tags = ['PockyCollections'];
