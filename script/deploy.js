// Import necessary packages
const { ethers } = require('hardhat')

// Replace these with actual addresses on the network you are deploying to.
const WETH9_ADDRESS = '0x4200000000000000000000000000000000000006' // Replace with the actual WETH address
const FACTORY_OWNER_ADDRESS = '0xE6f27ad7e6b7297F7324a0a7d10Dd9b75d2F4d73' // Replace with the deployer's address

async function main() {
  // Get the contract factories for deployment
  const UniswapV3Factory = await ethers.getContractFactory('UniswapV3Factory')
  //   const NonfungiblePositionManager = await ethers.getContractFactory(
  //     "NonfungiblePositionManager"
  //   );
  //   const SwapRouter = await ethers.getContractFactory("SwapRouter");
  //   const Quoter = await ethers.getContractFactory("Quoter");

  // Deploy Uniswap V3 Factory

  console.log('Deploying UniswapV3Factory...')
  const factory = UniswapV3Factory(0x62706efd1fb79e0449837d9eb6d3ea65bc8a97ba)

  console.log('UniswapV3Factory deployed at:', factory.address)

  //   // Deploy Nonfungible Position Manager
  //   console.log("Deploying NonfungiblePositionManager...");
  //   const positionManager = await NonfungiblePositionManager.deploy(
  //     factory.address,
  //     WETH9_ADDRESS
  //   );
  //   await positionManager.deployed();
  //   console.log(
  //     "NonfungiblePositionManager deployed at:",
  //     positionManager.address
  //   );

  //   // Deploy Swap Router
  //   console.log("Deploying SwapRouter...");
  //   const swapRouter = await SwapRouter.deploy(factory.address, WETH9_ADDRESS);
  //   await swapRouter.deployed();
  //   console.log("SwapRouter deployed at:", swapRouter.address);

  //   // Deploy Quoter
  //   console.log("Deploying Quoter...");
  //   const quoter = await Quoter.deploy(factory.address, WETH9_ADDRESS);
  //   await quoter.deployed();
  //   console.log("Quoter deployed at:", quoter.address);

  console.log('Deployment completed successfully!')
}

// Handle errors and run the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error)
    process.exit(1)
  })
