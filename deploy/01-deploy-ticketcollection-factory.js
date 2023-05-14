const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    log("----------------------------------------------------");
    arguments = [];
    await deploy("TicketCollectionFactory", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: 1,
    });
};

module.exports.tags = ["all", "ticketcollectionfactory", "main"];
