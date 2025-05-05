# Lendswap V1 Core

Lendswap V1 Core is a revolutionary DeFi protocol that combines the concentrated liquidity mechanism of Uniswap V3 with lending protocols to significantly enhance capital efficiency for liquidity providers.

## Concept

The key innovation of Lendswap is based on a critical insight: Uniswap V3 pools don't actually need to hold assets in their contracts at all times. Through mathematical proofs, we've demonstrated that assets can be withdrawn from Uniswap V3 contracts and deposited into lending protocols, all while maintaining the core functionality of the AMM.

### Key Insight: Uniswap as a Ledger

**The most important concept:** In Lendswap, the Uniswap V3 pool can function with zero assets stored in it. The pool primarily serves as a ledger that tracks positions and price movements, not as a storage facility for assets. When a swap occurs:

1. The necessary assets are withdrawn from the lending protocol (via the Vault contract)
2. The swap executes as normal
3. The resulting assets can be immediately redeposited into the lending protocol

This approach proves that AMMs like Uniswap V3 can achieve much higher capital efficiency while maintaining their core functionality.

### How It Works

1. **Capital Efficiency Enhancement:** By withdrawing assets from Uniswap V3 pools and depositing them into lending protocols, Lendswap maximizes the productive use of capital.

2. **Health Factor Monitoring:** The system continuously ensures that the lending protocol's health factor remains within safe parameters, preventing liquidations.

3. **Dual Revenue Streams:** Liquidity providers benefit from both trading fees (from Uniswap V3) and lending yields (from the lending protocol), significantly boosting overall returns.

4. **Risk Management:** Smart contract logic ensures that assets can be recalled from lending protocols when needed for swaps in the Uniswap V3 pool.

## Core Components

- **LendswapV3Pool:** Enhanced version of Uniswap V3 Pool that integrates with lending protocols
- **LendswapV3Factory:** Factory contract for creating and managing Lendswap pools
- **Vault:** Manages the interaction between Uniswap V3 positions and lending protocols

## Testing

To test the Lendswap V1 Core protocol:

1. **Install Dependencies:**
   ```bash
   forge install
   ```

2. **Run Tests:**
   ```bash
   forge test
   ```

3. **Run Tests with Gas Report:**
   ```bash
   forge test --gas-report
   ```

4. **Run Specific Test Files:**
   ```bash
   forge test --match-path test/LendswapV3Pool.t.sol
   ```

5. **Coverage Report:**
   ```bash
   forge coverage
   ```

## Risk Considerations

While this approach significantly enhances capital efficiency, there are two primary concerns:

1. **Network Congestion Risk:** During periods of high network congestion, transactions may incur higher gas fees since each swap requires an additional withdrawal from the lending protocol. This could impact profitability during extreme market conditions.

2. **Liquidity Availability Risk:** There's a theoretical risk that the lending protocol might not have sufficient deposits to service a withdrawal needed for a swap. This is mitigated through steep interest rate curves in the lending protocol, which ensure borrowing cannot exceed safe thresholds.

## Security Considerations

- The protocol maintains a buffer of assets in the Uniswap V3 pool to handle immediate swap needs
- Withdrawal mechanisms from lending protocols are optimized for gas efficiency and speed
- Fallback mechanisms are in place to handle lending protocol failures

## Mathematical Proof

The repository includes formal verification that demonstrates how Uniswap V3's core mathematical principles remain intact even when assets are partially deployed to lending protocols. The key insight is that as long as assets can be retrieved within a reasonable time frame (typically within one transaction), the AMM functions correctly.

## Future Work

- Integration with multiple lending protocols
- Optimized rebalancing strategies to maximize yields
- Cross-chain implementations
- Governance mechanisms for parameter adjustments

## License

[MIT](LICENSE)
