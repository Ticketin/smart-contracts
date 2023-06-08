const { network } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments, ethers }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const pockyCollections = await deployments.get('PockyCollections');
  const pockyTicket = await ethers.getContract('Ticket');

  log('----------------------------------------------------');
  const deployResult = await deploy('PockyTicketSales', {
    from: deployer,
    args: [pockyCollections.address, pockyTicket.address],
    waitConfirmations: 1,
  });
  if (deployResult.newlyDeployed) {
    log(`contract PockyTicketSales deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
    log(`granting Ticket.MINTER_ROLE to PockyTicketSales (${deployResult.address})`);
    await pockyTicket.grantRole(await pockyTicket.MINTER_ROLE(), deployResult.address);
  }
};

module.exports.tags = ['PockyTicketSales'];
