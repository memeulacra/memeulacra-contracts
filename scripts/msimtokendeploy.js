const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const Token = await ethers.getContractFactory("MsimToken");
    const token = await Token.deploy("Memeulacra", "MSIM");

    await token.waitForDeployment();

    console.log("Token deployed to:", await token.getAddress());
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
