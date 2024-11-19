// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import 'forge-std/Test.sol';
import '../contracts/UniswapV3Factory.sol';
import '../contracts/UniswapV3Pool.sol';
import '../contracts/MockERC20.sol';
import '../contracts/libraries/TickMath.sol';

contract UniswapV3PoolTest is Test, IUniswapV3MintCallback {
    UniswapV3Factory public factory;
    UniswapV3Pool public pool;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    uint24 public constant FEE = 3000; // 0.3%
    uint160 public constant INITIAL_SQRT_PRICE_X96 = 79228162514264337593543950336; // sqrt(1) * 2^96
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 1e18;

    function setUp() public {
        // Deploy the UniswapV3Factory contract
        factory = new UniswapV3Factory();

        // Deploy MockERC20 tokens
        tokenA = new MockERC20('TokenA', 'TKA', INITIAL_SUPPLY);
        tokenB = new MockERC20('TokenB', 'TKB', INITIAL_SUPPLY);

        // Create a new pool in the factory
        address poolAddress = factory.createPool(address(tokenA), address(tokenB), FEE);
        pool = UniswapV3Pool(poolAddress);

        // Initialize the pool with the starting sqrt price
        pool.initialize(INITIAL_SQRT_PRICE_X96);

        // Approve the pool to transfer tokens on behalf of this contract
        tokenA.approve(address(pool), type(uint256).max);
        tokenB.approve(address(pool), type(uint256).max);
    }

    function testAddAndRemoveLiquidity() public {
        getPoolState();
        getTokenBalances();
        // Define the tick range for liquidity
        int24 tickLower = -600;
        int24 tickUpper = 600;
        uint160 tickLowerSqrtPriceX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 tickUpperSqrtPriceX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        console.log('TickLower sqrtPriceX96:', uint256(tickLowerSqrtPriceX96));
        console.log('TickUpper sqrtPriceX96:', uint256(tickUpperSqrtPriceX96));
        uint128 liquidity = 1_000_000;

        // Add liquidity to the pool
        (uint256 amount0, uint256 amount1) = pool.mint(address(this), tickLower, tickUpper, liquidity, '');
        getTokenBalances();

        // Verify the amounts of token0 and token1 added to the pool
        assertGt(amount0, 0, 'Amount0 should be greater than 0');
        assertGt(amount1, 0, 'Amount1 should be greater than 0');
        console.log('Amount0 added:', amount0);
        console.log('Amount1 added:', amount1);

        // Remove a portion of liquidity from the pool
        uint128 liquidityToRemove = liquidity / 2;
        (uint256 amount0Burned, uint256 amount1Burned) = pool.burn(tickLower, tickUpper, liquidityToRemove);
        console.log('After burn');
        getTokenBalances();

        // Verify the amounts of token0 and token1 removed from the pool
        assertGt(amount0Burned, 0, 'Amount0 burned should be greater than 0');
        assertGt(amount1Burned, 0, 'Amount1 burned should be greater than 0');
        console.log('Amount0 burned:', amount0Burned);
        console.log('Amount1 burned:', amount1Burned);

        // Collect tokens back to this contract
        pool.collect(address(this), tickLower, tickUpper, type(uint128).max, type(uint128).max);
        console.log('After collect');

        getPoolState();
        getTokenBalances();
    }

    function getPoolState() public view returns (uint160 sqrtPriceX96, int24 tick, uint128 liquidity) {
        // Retrieve the slot0 data from the pool
        (sqrtPriceX96, tick, , , , , ) = pool.slot0();
        // Retrieve the liquidity data from the pool
        liquidity = pool.liquidity();

        console.log('Current sqrtPriceX96:', uint256(sqrtPriceX96));
        console.log('Current tick:', tick);
        console.log('Current liquidity:', uint256(liquidity));
    }

    function getTokenBalances() public view returns (uint256 balanceTokenA, uint256 balanceTokenB) {
        // Retrieve token balances in the pool
        balanceTokenA = tokenA.balanceOf(address(pool));
        balanceTokenB = tokenB.balanceOf(address(pool));

        // Log the balances for debugging
        console.log('TokenA balance in pool:', balanceTokenA);
        console.log('TokenB balance in pool:', balanceTokenB);
    }

    function uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes calldata) external override {
        require(msg.sender == address(pool), 'Invalid callback sender');

        // Log for debugging
        console.log('Callback invoked with amount0Owed:', amount0Owed);
        console.log('Callback invoked with amount1Owed:', amount1Owed);

        // Transfer the owed amounts to the pool
        if (amount0Owed > 0) {
            tokenA.transfer(msg.sender, amount0Owed);
        }
        if (amount1Owed > 0) {
            tokenB.transfer(msg.sender, amount1Owed);
        }

        // Log balances after transfer
        console.log('TokenA balance of pool after transfer:', tokenA.balanceOf(address(pool)));
        console.log('TokenB balance of pool after transfer:', tokenB.balanceOf(address(pool)));
    }
}
