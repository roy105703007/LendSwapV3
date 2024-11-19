// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import 'forge-std/Test.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract UniswapV3RealTokenTest is Test {
    uint256 public forkId;
    IUniswapV3Factory public factory;
    IUniswapV3Pool public pool;
    IERC20 public tokenA;
    IERC20 public tokenB;

    uint24 public constant FEE = 3000; // 0.3%
    uint160 public constant INITIAL_SQRT_PRICE_X96 = 79228162514264337593543950336;

    function setUp() public {
        forkId = vm.createFork('https://mainnet.infura.io/v3/db89e26032c74df59ba1363e3c3979e9');
        vm.selectFork(forkId);
        // 使用真實代幣地址 (Ethereum Mainnet)
        tokenA = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
        tokenB = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC

        // 初始化 Uniswap V3 Factory 地址 (Mainnet)
        factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    }

    function testInitializePool() public {
        // 創建池
        address poolAddress = factory.getPool(address(tokenA), address(tokenB), FEE);
        pool = IUniswapV3Pool(poolAddress);

        // 初始化池，設置初始價格
        // pool.initialize(INITIAL_SQRT_PRICE_X96);

        // 驗證初始價格是否正確
        (uint160 sqrtPriceX96, , , , , , ) = pool.slot0();
        assert(sqrtPriceX96 != 0);
        console.log('Initial sqrtPriceX96:', uint256(sqrtPriceX96));
    }
}
