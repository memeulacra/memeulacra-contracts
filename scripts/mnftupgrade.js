// const { ethers } = require("hardhat");
// const hre = require("hardhat");
import pkg from 'hardhat';
const { ethers, upgrades, run } = pkg;
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const TokenVNext = await ethers.getContractFactory("MemeNFT");
    //const token = await Token.deploy("Memeulacra", "MSIM");
    const token = await upgrades.upgradeProxy(process.env.MNFT_PROXY_ADDRESS, TokenVNext);

    await token.waitForDeployment();

    const deployedAddress = await token.getAddress();
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(deployedAddress);

    console.log("Waiting for deployment confirmation...");
    await token.deploymentTransaction()?.wait(3);
    console.log("Contract deploy at least 3 blocks ago, upgrade complete");

    console.log("Token proxy deployed to:", deployedAddress);
    console.log("Token Implementation Address:", implementationAddress);

    console.log("Verifying contract on Basescan...");
    try {
        await run("verify:verify", {
            address: implementationAddress,
            constructorArguments: [],
        });
        console.log("Implementation contract verified!");
    } catch (error) {
        if (error.message.toLowerCase().includes("already verified")) {
            console.log("Implementation contract already verified!");
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
