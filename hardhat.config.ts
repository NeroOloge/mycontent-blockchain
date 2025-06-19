import "dotenv/config"
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  sourcify: {
    enabled: true
  },
  networks: {
    sepolia: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/otxc766CqQlSlD0yx5L02rjb_fcLac8Q',
      accounts: [process.env.PRIVATE_KEY_1!, process.env.PRIVATE_KEY_2!]
    }
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.SEPOLIA_API_KEY!
    }
  }
};

export default config;