import "dotenv/config"
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: 'https://eth-sepolia.g.alchemy.com/v2/otxc766CqQlSlD0yx5L02rjb_fcLac8Q',
      accounts: [process.env.PRIVATE_KEY_1!, process.env.PRIVATE_KEY_2!]
    }
  }
};

export default config;
