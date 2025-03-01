import { ethers } from "ethers";
import { GoldRushClient, ChainName } from "@covalenthq/client-sdk";
import * as dotenv from "dotenv";

dotenv.config();

const client = new GoldRushClient(process.env.GOLDRUSH_API_KEY);

// const ApiServices = async () => {
//     const client = new GoldRushClient(process.env.GOLDRUSH_API_KEY);
//     const resp = await client.BaseService.getLogEventsByAddress({chainName: ChainName.BASE_SEPOLIA_TESTNET, walletAddress: "0x83b623035da194d28DB1b2b10aB4bD67F16a09C2"});
//     console.log(resp.data);
// };

async function filterOwnedContracts(walletAddress, provider) {
    const fromBlock = 22501765; // Adjust for your contract deployment block
    const toBlock = "latest";

    const options = {
        method: 'GET',
        headers: {Authorization: 'Bearer ' + process.env.GOLDRUSH_API_KEY}
    };
    const ownershipTransferredEvent = ethers.id("NewMemeTokenFactoryEvent(address,address)");
    const qResult = await fetch('https://api.covalenthq.com/v1/base-sepolia-testnet/events/address/0x83b623035da194d28DB1b2b10aB4bD67F16a09C2/?starting-block=22501765', options)
        .then(response => response.json())
        // .then(response => console.log(response))
        .catch(err => console.error(err));

    const events = qResult.data.items.filter((log) => log.raw_log_topics[0] === ownershipTransferredEvent && ethers.getAddress('0x' + log.raw_log_topics[1].slice(-40)) === walletAddress);

    return events.map((evt) => ethers.getAddress('0x' + evt.raw_log_topics[2].slice(-40)))

}

const erc721abi = [
    'function balanceOf(address owner) view returns (uint256)',
    'function tokenOfOwnerByIndex(address owner, uint256 index) view returns (uint256)',
    'function getImageURL(uint256 tokenId) external view returns (string memory)',
    'function getImageHash(uint256 tokenId) external view returns (bytes32)',
    'event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)',
];


const erc20abi = [
    'function name() view returns (string)',
    'function symbol() view returns (string)',
    'function balanceOf(address owner) view returns (uint256)',
];

async function getTokenDetails(accountAddress, tokenAddress, provider) {

    const tokenContract = new ethers.Contract(tokenAddress, erc20abi, provider);
    try {
      const name = await tokenContract.name();
      const symbol = await tokenContract.symbol();
      const balance = await tokenContract.balanceOf(accountAddress);
  
      console.log(`Token Name: ${name}`);
      console.log(`Token Symbol: ${symbol}`);
      console.log(`Token Balance: ${ethers.formatUnits(balance, 18)}`);
    } catch (error) {
      console.error('Error fetching token details:', error);
    }
}


async function getNFTs(accountAddress, nftContractAddress, provider) {
    const nftContract = new ethers.Contract(nftContractAddress, erc721abi, provider);
    try {
        const balance = await nftContract.balanceOf(accountAddress); // Get the number of tokens owned
        if (balance > 0) {
            console.log(`${accountAddress} owns ${balance.toString()} NFTs.`);
        } else {
            console.log(`${accountAddress} does not own any NFTs.`);
        }

        // - requires 721 enumeration extension
        for (let i = 0; i < balance; i++) {
            const tokenId = await nftContract.tokenOfOwnerByIndex(accountAddress, i);
            //tokenIds.push(tokenId.toString());
            const tokenUrl = await nftContract.getImageURL(tokenId);
            console.log(`Token owned by ${tokenId}: ${tokenUrl}`)
        }

    } catch (error) {
        console.error('Error fetching token IDs:', error);
    }
}


async function main() {
    const queryAddress = "0x377C2A416B5b43D970681D614196d6e773032999"; // Replace with your wallet address

    //const rpcUrl = "https://sepolia.base.org";
    const baseSepoliaProvider = new ethers.JsonRpcProvider("https://sepolia.base.org");
    

    const query = await filterOwnedContracts(queryAddress, baseSepoliaProvider);

    console.log("User MSIM:");
    await getTokenDetails(queryAddress, "0x96BeEBB6bC25362baeE97d5a97157AE6314219ef", baseSepoliaProvider);

    console.log("\nUser Owned Meme Tokens:");
    const p = [];
    query.forEach(element => {
        p.push(getTokenDetails(queryAddress, element, baseSepoliaProvider));        
    });
    await Promise.all(p);

    console.log("\nUser Owned Meme NTFs:");
    await getNFTs(queryAddress, process.env.MNFT_PROXY_ADDRESS, baseSepoliaProvider);
    //console.log("Query:", query);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });