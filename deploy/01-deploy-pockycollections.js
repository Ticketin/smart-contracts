const { network } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();

  log('----------------------------------------------------');
  const ticketSVGRenderer = await deploy('TicketSVGRenderer', { from: deployer });
  if (ticketSVGRenderer.newlyDeployed) {
    console.log('Deployed TicketSVGRenderer to:', ticketSVGRenderer.address);
  }

  const deployResult = await deploy('PockyCollections', {
    from: deployer,
    args: [],
    waitConfirmations: 1,
    libraries: {
      TicketSVGRenderer: ticketSVGRenderer.address,
    },
  });
  if (deployResult.newlyDeployed) {
    log(`contract PockyCollections deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
  }
};
module.exports.tags = ['PockyCollections'];
