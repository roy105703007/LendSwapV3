import 'hardhat-typechain'
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'
import '@nomiclabs/hardhat-etherscan'

import * as dotenv from 'dotenv'

// Load environment variables
dotenv.config()

const signerAccounts = process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : []
const seitraceKey = process.env.SEITRACE_KEY || ''

export default {
  networks: {
    sei_atlantic_2: {
      url: `https://evm-rpc-testnet.sei-apis.com`,
      chainId: 1328,
      accounts: signerAccounts,
    },
    'arbitrum-sepolia': {
      url: `https://sepolia-rollup.arbitrum.io/rpc/`,
      chainId: 421614,
      accounts: signerAccounts,
    },
    hardhat: {
      allowUnlimitedContractSize: false,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    ropsten: {
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    goerli: {
      url: `https://goerli.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    kovan: {
      url: `https://kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    arbitrumRinkeby: {
      url: `https://arbitrum-rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    arbitrum: {
      url: `https://arbitrum-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    optimismKovan: {
      url: `https://optimism-kovan.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    optimism: {
      url: `https://optimism-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    mumbai: {
      url: `https://polygon-mumbai.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    polygon: {
      url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
    },
    bnb: {
      url: `https://bsc-dataseed.binance.org/`,
    },
  },
  etherscan: {
    apiKey: {
      sei_atlantic_2: seitraceKey,
    },
    customChains: [
      {
        network: 'sei_atlantic_2',
        chainId: 1328,
        urls: {
          apiURL: 'https://seitrace.com/atlantic-2/api',
          browserURL: 'https://seitrace.com',
        },
      },
    ],
  },
  solidity: {
    version: '0.7.6',
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
      metadata: {
        // do not include the metadata hash, since this is machine dependent
        // and we want all generated code to be deterministic
        // https://docs.soliditylang.org/en/v0.7.6/metadata.html
        bytecodeHash: 'none',
      },
    },
  },
}
