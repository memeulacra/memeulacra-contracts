import { ethers } from "ethers";
import * as dotenv from "dotenv";
import fs from "fs";

dotenv.config();

async function main() {
    const tokenAddress = "0xdacA95746049E8eB51bCaC8d3c00Ad4D463550d6"; // Replace with your deployed contract address

    // const MsimTokenABI = [
    //     {
    //         inputs: [],
    //         name: "name",
    //         outputs: [{ internalType: "string", name: "", type: "string" }],
    //         stateMutability: "view",
    //         type: "function"
    //     },
    //     {
    //         inputs: [],
    //         name: "symbol",
    //         outputs: [{ internalType: "string", name: "", type: "string" }],
    //         stateMutability: "view",
    //         type: "function"
    //     },
    //     {
    //         inputs: [],
    //         name: "totalSupply",
    //         outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    //         stateMutability: "view",
    //         type: "function"
    //     },
    //     {
    //         inputs: [],
    //         name: "decimals",
    //         outputs: [{ internalType: "uint8", name: "", type: "uint8" }],
    //         stateMutability: "view",
    //         type: "function"
    //     },
    //     {
    //         inputs: [
    //             { internalType: "address", name: "to", type: "address" }
    //         ],
    //         name: "mint",
    //         outputs: [],
    //         stateMutability: "nonpayable",
    //         type: "function"
    //     },
    //     {
    //         inputs: [
    //             { internalType: "uint256", name: "amount", type: "uint256" }
    //         ],
    //         name: "burn",
    //         outputs: [],
    //         stateMutability: "nonpayable",
    //         type: "function"
    //     },
    //     {
    //         inputs: [
    //             { internalType: "address", name: "from", type: "address" },
    //             { internalType: "uint256", name: "amount", type: "uint256" }
    //         ],
    //         name: "burnFrom",
    //         outputs: [],
    //         stateMutability: "nonpayable",
    //         type: "function"
    //     }
    // ];

    // Read the ABI JSON file
    const abiPath = './artifacts/contracts/MsimToken.sol/MsimToken.json';
    const abiJson = fs.readFileSync(abiPath);
    const MsimTokenABI = JSON.parse(abiJson).abi;

    // Create contract instance
    const provider = new ethers.JsonRpcProvider(process.env.BASE_SEPOLIA_RPC_URL); // Replace with your provider URL
    const Token = new ethers.Contract(tokenAddress, MsimTokenABI, provider);

    try {
        console.log("Contract Address:", tokenAddress);
        // Fetch the token name
        const name = await Token.name();
        console.log("Token Name:", name);

        // Fetch the token symbol
        const symbol = await Token.symbol();
        console.log("Token Symbol:", symbol);

        // Fetch the total supply and format it with 18 decimal places
        const totalSupply = await Token.totalSupply();
        console.log("Total Supply1:", totalSupply.toString());

    } catch (error) {
        console.error("Error:", error);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });