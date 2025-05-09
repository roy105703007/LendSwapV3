// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";
import "../contracts/UniswapV3Factory.sol";
import "../contracts/UniswapV3Pool.sol";
import "../contracts/MockERC20.sol";
import "../contracts/libraries/TickMath.sol";

contract UniswapV3PoolTest is Test, IUniswapV3MintCallback, IUniswapV3SwapCallback {
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
        MockERC20 tempTokenA = new MockERC20("TokenA", "TKA", INITIAL_SUPPLY);
        MockERC20 tempTokenB = new MockERC20("TokenB", "TKB", INITIAL_SUPPLY);

        // Sort tokens to determine token0 and token1
        if (address(tempTokenA) < address(tempTokenB)) {
            tokenA = tempTokenA;
            tokenB = tempTokenB;
        } else {
            tokenA = tempTokenB;
            tokenB = tempTokenA;
        }

        console.log("Token0 address:", address(tokenA));
        console.log("Token1 address:", address(tokenB));

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
        getTokenBalancesInPool();
        // Define the tick range for liquidity
        int24 tickLower = -600;
        int24 tickUpper = 600;
        uint160 tickLowerSqrtPriceX96 = TickMath.getSqrtRatioAtTick(tickLower);
        uint160 tickUpperSqrtPriceX96 = TickMath.getSqrtRatioAtTick(tickUpper);
        console.log("TickLower sqrtPriceX96:", uint256(tickLowerSqrtPriceX96));
        console.log("TickUpper sqrtPriceX96:", uint256(tickUpperSqrtPriceX96));
        uint128 liquidity = 1_000_000;

        // Add liquidity to the pool
        (uint256 amount0, uint256 amount1) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        getTokenBalancesInPool();

        // Verify the amounts of token0 and token1 added to the pool
        assertGt(amount0, 0, "Amount0 should be greater than 0");
        assertGt(amount1, 0, "Amount1 should be greater than 0");
        console.log("Amount0 added:", amount0);
        console.log("Amount1 added:", amount1);

        // Remove a portion of liquidity from the pool
        uint128 liquidityToRemove = liquidity / 2;
        (uint256 amount0Burned, uint256 amount1Burned) = pool.burn(tickLower, tickUpper, liquidityToRemove);
        console.log("After burn");
        getTokenBalancesInPool();

        // Verify the amounts of token0 and token1 removed from the pool
        assertGt(amount0Burned, 0, "Amount0 burned should be greater than 0");
        assertGt(amount1Burned, 0, "Amount1 burned should be greater than 0");
        console.log("Amount0 burned:", amount0Burned);
        console.log("Amount1 burned:", amount1Burned);

        // Collect tokens back to this contract
        pool.collect(address(this), tickLower, tickUpper, type(uint128).max, type(uint128).max);
        console.log("After collect");

        getPoolState();
        getTokenBalancesInPool();
    }

    function testSwap() public {
        // Step 1: Add liquidity to enable swapping
        int24 tickLower = -600;
        int24 tickUpper = 600;
        uint128 liquidity = 1_000_000;

        console.log("Before mint:");

        // getTickInfo(0);
        // getTickInfo(-20);
        // getTickInfo(tickLower);
        // getTickInfo(tickUpper);

        (uint256 amount0Added, uint256 amount1Added) = pool.mint(address(this), tickLower, tickUpper, liquidity, "");
        console.log("Liquidity added. Amount0:", amount0Added, "Amount1:", amount1Added);

        console.log("After mint:");

        // getTickInfo(0);
        // getTickInfo(-20);
        // getTickInfo(tickLower);
        // getTickInfo(tickUpper);

        getTokenBalancesInPool();

        // Step 2: Perform a swap
        uint256 amountSpecified = 1000; // Swap 1000 tokenA for tokenB
        uint160 sqrtPriceLimitX96 = TickMath.getSqrtRatioAtTick(-700); // Define a price limit for the swap

        console.log("Before swap:");
        // getTickInfo(0);
        // getTickInfo(-20);
        // getTickInfo(tickLower);
        // getTickInfo(tickUpper);
        getPoolState();
        getTokenBalancesInPool();

        uint256 beforeSwapTokenABalance = tokenA.balanceOf(address(this));
        (int256 amount0, int256 amount1) = pool.swap(
            address(this), // Recipient
            true, // zeroForOne: tokenA for tokenB
            int256(amountSpecified), // Amount specified
            sqrtPriceLimitX96, // Price limit
            "" // Callback data
        );

        console.log("After swap:");
        console.log("The delta of the balance of token0 of the pool:", amount0);
        console.log("The delta of the balance of token1 of the pool", amount1);

        // getTickInfo(0);
        // getTickInfo(-20);
        // getTickInfo(tickLower);
        // getTickInfo(tickUpper);

        // Step 3: Verify balances and state after swap
        getPoolState();
        getTokenBalancesInPool();

        assertGt(uint256(amount1), 0, "Swap should result in a positive amount1");
        assertEq(
            tokenA.balanceOf(address(this)), beforeSwapTokenABalance - amountSpecified, "TokenA balance should decrease"
        );
        assertGt(tokenB.balanceOf(address(this)), 0, "TokenB balance should increase");
    }

    function testCrossTickSwap() public {
        // Step 1: Add liquidity in two different ranges

        int24 tickLower1 = -60;
        int24 tickUpper1 = 60;
        uint128 liquidity1 = 7_000;

        int24 tickLower2 = -600;
        int24 tickUpper2 = -480;
        uint128 liquidity2 = 500_000;

        console.log("Before adding liquidity for range 1:");
        // getTickInfo(tickLower1);
        // getTickInfo(tickUpper1);

        (uint256 amount0Added1, uint256 amount1Added1) =
            pool.mint(address(this), tickLower1, tickUpper1, liquidity1, "");
        console.log("Liquidity added for range 1. Amount0:", amount0Added1, "Amount1:", amount1Added1);

        console.log("After adding liquidity for range 1:");
        // getTickInfo(tickLower1);
        // getTickInfo(tickUpper1);

        console.log("Before adding liquidity for range 2:");
        // getTickInfo(tickLower2);
        // getTickInfo(tickUpper2);

        (uint256 amount0Added2, uint256 amount1Added2) =
            pool.mint(address(this), tickLower2, tickUpper2, liquidity2, "");
        console.log("Liquidity added for range 2. Amount0:", amount0Added2, "Amount1:", amount1Added2);

        console.log("After adding liquidity for range 2:");
        // getTickInfo(tickLower2);
        // getTickInfo(tickUpper2);

        // Step 2: Perform a swap that crosses multiple ticks
        uint256 amountSpecified = 1500; // Swap 1500 tokenA for tokenB
        uint160 sqrtPriceLimitX96 = TickMath.getSqrtRatioAtTick(-900); // Define a price limit for the swap

        console.log("Before swap:");
        // getTickInfo(tickLower1);
        // getTickInfo(tickUpper1);
        // getTickInfo(tickLower2);
        // getTickInfo(tickUpper2);
        getPoolState();
        getTokenBalancesInPool();

        (int256 amount0Delta, int256 amount1Delta) = pool.swap(
            address(this), // Recipient
            true, // zeroForOne: tokenA for tokenB
            int256(amountSpecified), // Amount specified
            sqrtPriceLimitX96, // Price limit
            "" // Callback data
        );

        console.log("After swap:");
        console.log("Amount0Delta (TokenA):", uint256(amount0Delta > 0 ? amount0Delta : -amount0Delta));
        console.log("Amount1Delta (TokenB):", uint256(amount1Delta > 0 ? amount1Delta : -amount1Delta));

        // getTickInfo(tickLower1);
        // getTickInfo(tickUpper1);
        // getTickInfo(tickLower2);
        // getTickInfo(tickUpper2);
        getPoolState();
        getTokenBalancesInPool();

        // Verify the swap affected both ranges
        assertGt(uint256(amount1Delta), 0, "Swap should result in a positive amount of TokenB");
    }

    function getPoolState() public view returns (uint160 sqrtPriceX96, int24 tick, uint128 liquidity) {
        // Retrieve the slot0 data from the pool
        (sqrtPriceX96, tick,,,,,) = pool.slot0();
        // Retrieve the liquidity data from the pool
        liquidity = pool.liquidity();

        console.log("Current sqrtPriceX96:", uint256(sqrtPriceX96));
        console.log("Current tick:", tick);
        console.log("Current liquidity:", uint256(liquidity));
    }

    function getTokenBalancesInPool() public view returns (uint256 balanceTokenA, uint256 balanceTokenB) {
        // Retrieve token balances in the pool
        balanceTokenA = tokenA.balanceOf(address(pool));
        balanceTokenB = tokenB.balanceOf(address(pool));

        // Log the balances for debugging
        console.log("TokenA balance in pool:", balanceTokenA);
        console.log("TokenB balance in pool:", balanceTokenB);
    }

    function getTickInfo(int24 tick) public view {
        // Get the information for the given tick
        (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        ) = pool.ticks(tick);

        // Log the tick information
        console.log("Tick:", tick);
        console.log("LiquidityGross:", uint256(liquidityGross));
        console.log("LiquidityNet:", int256(liquidityNet));
        console.log("FeeGrowthOutside0X128:", feeGrowthOutside0X128);
        console.log("FeeGrowthOutside1X128:", feeGrowthOutside1X128);
        console.log("TickCumulativeOutside:", tickCumulativeOutside);
        console.log("SecondsPerLiquidityOutsideX128:", uint256(secondsPerLiquidityOutsideX128));
        console.log("SecondsOutside:", uint256(secondsOutside));
        console.log("Initialized:", initialized);
    }

    function uniswapV3MintCallback(uint256 amount0Owed, uint256 amount1Owed, bytes calldata) external override {
        require(msg.sender == address(pool), "Invalid callback sender");

        // Log for debugging
        console.log("Callback invoked with amount0Owed:", amount0Owed);
        console.log("Callback invoked with amount1Owed:", amount1Owed);

        // Transfer the owed amounts to the pool
        if (amount0Owed > 0) {
            tokenA.transfer(msg.sender, amount0Owed);
        }
        if (amount1Owed > 0) {
            tokenB.transfer(msg.sender, amount1Owed);
        }

        // Log balances after transfer
        console.log("TokenA balance of pool after transfer:", tokenA.balanceOf(address(pool)));
        console.log("TokenB balance of pool after transfer:", tokenB.balanceOf(address(pool)));
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata) external override {
        require(msg.sender == address(pool), "Invalid callback sender");

        // Log for debugging
        console.log("Callback invoked with amount0Delta:", amount0Delta);
        console.log("Callback invoked with amount1Delta:", amount1Delta);

        if (amount0Delta > 0) {
            tokenA.transfer(msg.sender, uint256(amount0Delta));
        }
        if (amount1Delta > 0) {
            tokenB.transfer(msg.sender, uint256(amount1Delta));
        }

        // Log balances after swap
        console.log("TokenA balance of pool after swap:", tokenA.balanceOf(address(pool)));
        console.log("TokenB balance of pool after swap:", tokenB.balanceOf(address(pool)));
    }
}
