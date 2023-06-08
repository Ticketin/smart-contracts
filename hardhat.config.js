require('@nomicfoundation/hardhat-toolbox');
require('@nomiclabs/hardhat-ethers');
require('solidity-coverage');
require('@nomicfoundation/hardhat-network-helpers');
require('hardhat-deploy');
require('hardhat-gas-reporter');
require('dotenv').config();

const POLYGON_MAINNET_RPC_URL = process.env.POLYGON_MAINNET_RPC_URL || '';
const POLYGON_MUMBAI_RPC_URL = process.env.POLYGON_MUMBAI_RPC_URL || '';
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERSCAN_API_KEY = process.env.ETHERSCAN_API_KEY;
const COINMARKETCAP_API_KEY = process.env.COINMARKETCAP_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [
      {
        version: '0.8.17',
        settings: {
          optimizer: {
            enabled: true,
            runs: 1000,
          },
        },
      },
    ],
  },
  defaultNetwork: 'hardhat',
  networks: {
    hardhat: {
      chainId: 31337,
      // mining: {
      //     auto: false,
      //     interval: 5000,
      // },
    },
    polygonMainnet: {
      url: process.env.POLYGON_MAINNET_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 137,
      verify: {
        etherscan: { apiUrl: 'https://api.polygonscan.com/' },
      },
    },
    polygonMumbai: {
      url: POLYGON_MUMBAI_RPC_URL,
      accounts: [PRIVATE_KEY],
      chainId: 80001,
      verify: {
        etherscan: { apiUrl: 'https://api-testnet.polygonscan.com/' },
      },
    },
    localhost: {
      url: 'http://127.0.0.1:8545/',
      chainId: 31337,
    },
  },
  namedAccounts: {
    deployer: {
      default: 0,
    },
    user: {
      default: 1,
    },
  },
  verify: {
    etherscan: {
      apiKey: ETHERSCAN_API_KEY,
    },
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    coinmarketcap: COINMARKETCAP_API_KEY,
    token: 'MATIC',
  },
};
