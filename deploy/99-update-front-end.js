require("dotenv").config();
const fs = require("fs");
const { ethers } = require("hardhat");

const frontEndContractsFile = "../front-end/src/constants/contractAddresses.json";
const frontEndAbiLocation = "../front-end/src/constants/";

module.exports = async () => {
    if (process.env.UPDATE_FRONT_END) {
        console.log("Writing to front end...");
        await updateContractAddresses();
        await updateAbi();
        console.log("Front end written!");
    }
};

async function updateAbi() {
    const ticketCollectionFactory = await ethers.getContract("TicketCollectionFactory");
    console.log(ticketCollectionFactory);
    fs.writeFileSync(`${frontEndAbiLocation}TicketCollectionFactory.abi.json`, ticketCollectionFactory.interface.format(ethers.utils.FormatTypes.json));
    const ticketCollection = await ethers.getContract("TicketCollection");
    console.log(ticketCollection);
    fs.writeFileSync(`${frontEndAbiLocation}TicketCollection.abi.json`, ticketCollection.interface.format(ethers.utils.FormatTypes.json));
}

async function updateContractAddresses() {
    const chainId = network.config.chainId.toString();
    const ticketCollectionFactoryContract = await ethers.getContract("TicketCollectionFactory");
    const contractAddresses = JSON.parse(fs.readFileSync(frontEndContractsFile, "utf8"));
    if (chainId in contractAddresses) {
        if (!contractAddresses[chainId]["TicketCollectionFactory"].includes(ticketCollectionFactoryContract.address)) {
            contractAddresses[chainId]["TicketCollectionFactory"].push(ticketCollectionFactoryContract.address);
        }
    } else {
        contractAddresses[chainId] = { TicketCollectionFactory: [ticketCollectionFactoryContract.address] };
    }
    fs.writeFileSync(frontEndContractsFile, JSON.stringify(contractAddresses));
}

module.exports.tags = ["all", "frontend"];
