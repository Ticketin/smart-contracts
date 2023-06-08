const { network } = require('hardhat');

module.exports = async ({ getNamedAccounts, deployments, ethers }) => {
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const pockyCollections = await ethers.getContract('PockyCollections');

  log('----------------------------------------------------');
  const deployResult = await deploy('PockyAPIConsumer', {
    from: deployer,
    args: [pockyCollections.address],
    waitConfirmations: 1,
  });
  if (deployResult.newlyDeployed) {
    log(`contract PockyAPIConsumer deployed at ${deployResult.address} using ${deployResult.receipt.gasUsed} gas`);
    log(`granting PockyAPIConsumer.RESULT_ORACLE_ROLE to PockyAPIConsumer (${deployResult.address})`);
    await pockyCollections.grantRole(await pockyCollections.RESULT_ORACLE_ROLE(), deployResult.address);
  }
};

module.exports.tags = ['PockyAPIConsumer'];
