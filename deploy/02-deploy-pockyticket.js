const { network } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const pockyCollections = await deployments.get('PockyCollections');

  log('----------------------------------------------------');
  const deployResult = await deploy('Ticket', {
    from: deployer,
    args: [pockyCollections.address],
    waitConfirmations: 1,
  });
  if (deployResult.newlyDeployed) {
    log(`contract PockyTicket deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
  }
};
module.exports.tags = ['Ticket'];
