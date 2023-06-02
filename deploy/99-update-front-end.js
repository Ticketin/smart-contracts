require('dotenv').config();
const fs = require('fs');
const { ethers } = require('hardhat');

const frontEndContractsFile = '../client-admin/src/constants/contractAddresses.json';
const frontEndAbiLocation = '../client-admin/src/constants/';

module.exports = async () => {
  if (process.env.UPDATE_FRONT_END) {
    console.log('Writing to front end...');
    await updateContractAddresses();
    await updateAbi();
    console.log('Front end written!');
  }
  console.log(`update front-end...`);
};

async function updateAbi() {
  const pockyCollections = await ethers.getContract('PockyCollections');
  console.log(pockyCollections);
  fs.writeFileSync(
    `${frontEndAbiLocation}PockyCollections.abi.json`,
    pockyCollections.interface.format(ethers.utils.FormatTypes.json),
  );
  const ticket = await ethers.getContract('Ticket');
  console.log(ticket);
  fs.writeFileSync(`${frontEndAbiLocation}Ticket.abi.json`, ticket.interface.format(ethers.utils.FormatTypes.json));
}

async function updateContractAddresses() {
  const chainId = network.config.chainId.toString();
  const pockyCollectionsContract = await ethers.getContract('PockyCollections');
  const ticketContract = await ethers.getContract('Ticket');
  const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, 'utf8'));

  if (chainId in contractAddresses) {
    if (!contractAddresses[chainId]['PockyCollections'].includes(pockyCollectionsContract.address)) {
      contractAddresses[chainId]['PockyCollections'].push(pockyCollectionsContract.address);
    }
    if (!contractAddresses[chainId]['Ticket'].includes(ticketContract.address)) {
      contractAddresses[chainId]['Ticket'].push(ticketContract.address);
    }
  } else {
    contractAddresses[chainId] = {
      PockyCollections: [pockyCollectionsContract.address],
      Ticket: [ticketContract.address],
    };
  }

  fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses));
}

module.exports.tags = ['all', 'frontend'];
