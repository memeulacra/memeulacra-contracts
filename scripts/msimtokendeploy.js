const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const Token = await ethers.getContractFactory("MsimToken");
    const token = await Token.deploy("Memeulacra", "MSIM");

    await token.waitForDeployment();

    const deployedAddress = await token.getAddress();

    console.log("Waiting for deployment confirmation...");
    await token.deploymentTransaction()?.wait(3);
    console.log("Contract deploy at least 3 blocks ago");

    console.log("Token deployed to:", deployedAddress);

    console.log("Verifying contract on Basescan...");
    try {
        await hre.run("verify:verify", {
            address: deployedAddress,
            constructorArguments: ["Memeulacra", "MSIM"],
        });
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Contract already verified!");
        } else {
            throw error;
        }
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
