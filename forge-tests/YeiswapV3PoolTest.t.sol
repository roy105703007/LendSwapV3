// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import 'forge-std/Test.sol';
import '../contracts/YeiswapV3Factory.sol';
import '../contracts/YeiswapV3Pool.sol';
import '../contracts/MockERC20.sol';

contract YeiswapV3PoolTest is Test, IUniswapV3MintCallback {
    YeiswapV3Factory public factory;
    YeiswapV3Pool public pool;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    uint24 public constant FEE = 3000; // 0.3%
    uint160 public constant INITIAL_SQRT_PRICE_X96 = 79228162514264337593543950336; // sqrt(1) * 2^96
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 1e18;

    function setUp() public {
        // Deploy the YeiswapV3Factory contract
        factory = new YeiswapV3Factory();

        // Deploy MockERC20 tokens
        tokenA = new MockERC20('TokenA', 'TKA', INITIAL_SUPPLY);
        tokenB = new MockERC20('TokenB', 'TKB', INITIAL_SUPPLY);

        // Create a new pool in the factory
        address poolAddress = factory.createPool(address(tokenA), address(tokenB), FEE);
        pool = YeiswapV3Pool(poolAddress);

        // Initialize the pool with the starting sqrt price
        pool.initialize(INITIAL_SQRT_PRICE_X96);

        // Approve the pool to transfer tokens on behalf of this contract
        tokenA.approve(address(pool), type(uint256).max);
        tokenB.approve(address(pool), type(uint256).max);
    }

    function testAddAndRemoveLiquidity() public {
        // Define the tick range for liquidity
        int24 tickLower = -600;
        int24 tickUpper = 600;
        uint128 liquidity = 1_000_000;

        // Add liquidity to the pool
        (uint256 amount0, uint256 amount1) = pool.mint(address(this), tickLower, tickUpper, liquidity, '');

        // Verify the amounts of token0 and token1 added to the pool
        assertGt(amount0, 0, 'Amount0 should be greater than 0');
        assertGt(amount1, 0, 'Amount1 should be greater than 0');

        // Remove a portion of liquidity from the pool
        uint128 liquidityToRemove = liquidity / 2;
        (uint256 amount0Burned, uint256 amount1Burned) = pool.burn(tickLower, tickUpper, liquidityToRemove);

        // Collect tokens back to this contract
        pool.collect(address(this), tickLower, tickUpper, type(uint128).max, type(uint128).max);

        // Verify the amounts of token0 and token1 removed from the pool
        assertGt(amount0Burned, 0, 'Amount0 burned should be greater than 0');
        assertGt(amount1Burned, 0, 'Amount1 burned should be greater than 0');
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
