// Import necessary packages
const { ethers } = require('hardhat')

// Replace these with actual addresses on the network you are deploying to.

async function main() {
  // Get the contract factories for deployment
  const UniswapV3Factory = await ethers.getContractFactory('UniswapV3Factory')
  // const NonfungiblePositionManager = await ethers.getContractFactory('NonfungiblePositionManager')
  // const SwapRouter = await ethers.getContractFactory('SwapRouter')
  // const Quoter = await ethers.getContractFactory('Quoter')

  // Deploy Uniswap V3 Factory

  const factory = await UniswapV3Factory.deploy()

  console.log('UniswapV3Factory deployed at:', factory.address)

  // // Deploy Nonfungible Position Manager
  // console.log('Deploying NonfungiblePositionManager...')
  // const positionManager = await NonfungiblePositionManager.deploy(factory.address, WETH9_ADDRESS)
  // await positionManager.deployed()
  // console.log('NonfungiblePositionManager deployed at:', positionManager.address)

  // // Deploy Swap Router
  // console.log('Deploying SwapRouter...')
  // const swapRouter = await SwapRouter.deploy(factory.address, WETH9_ADDRESS)
  // await swapRouter.deployed()
  // console.log('SwapRouter deployed at:', swapRouter.address)

  // // Deploy Quoter
  // console.log('Deploying Quoter...')
  // const quoter = await Quoter.deploy(factory.address, WETH9_ADDRESS)
  // await quoter.deployed()
  // console.log('Quoter deployed at:', quoter.address)

  console.log('Deployment completed successfully!')
}

// Handle errors and run the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
