const { network } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();

    log("----------------------------------------------------");
    // Deploying with dummy args, since we only deploy for the factory contract to have access to the ABI
    arguments = ["x", "x", 1, 1, "x"];
    await deploy("TicketCollection", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: 1,
    });
};

module.exports.tags = ["all", "ticketcollection", "main"];
