import pkg from 'hardhat';
const { ethers, upgrades, run } = pkg;
import * as dotenv from "dotenv";

dotenv.config();

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const Factory = await ethers.getContractFactory("MemeulacraFactory");
    const factory = await upgrades.deployProxy(Factory, [], { initializer: "initialize" } );

    await factory.waitForDeployment();

    const deployedAddress = await factory.getAddress();
    const implementationAddress = await upgrades.erc1967.getImplementationAddress(deployedAddress);

    console.log("Waiting for deployment confirmation...");
    await factory.deploymentTransaction()?.wait(3);
    console.log("Contract deploy at least 3 blocks ago");

    console.log("factory proxy deployed to:", deployedAddress);
    console.log("factory Implementation Address:", implementationAddress);

    console.log("Granting Roles");
    if (process.env.UPGRADE_ADDRESS_1) {
        await factory.grantRole(factory.UPGRADER_ROLE(), process.env.UPGRADE_ADDRESS_1);
        console.log("UPGRADER_ROLE: 1 granted");
    }
    if (process.env.UPGRADE_ADDRESS_2) {
        await factory.grantRole(factory.UPGRADER_ROLE(), process.env.UPGRADE_ADDRESS_2);
        console.log("UPGRADER_ROLE: 2 granted");
    }
    if (process.env.UPGRADE_ADDRESS_3) {
        await factory.grantRole(factory.UPGRADER_ROLE(), process.env.UPGRADE_ADDRESS_3);
        console.log("UPGRADER_ROLE: 3 granted");
    }

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

    console.log("Verifying contract on Basescan...");
    try {
        await run("verify:verify", {
            address: deployedAddress,
            constructorArguments: [],
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
