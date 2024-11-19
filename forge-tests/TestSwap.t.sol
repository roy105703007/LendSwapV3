// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
pragma abicoder v2;

import 'forge-std/Test.sol';
import 'forge-std/console.sol';

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract UniswapV3SwapTest is Test {
    uint256 public forkId;
    ISwapRouter public router;
    IERC20 public tokenIn; // 交換的輸入代幣
    IERC20 public tokenOut; // 交換的輸出代幣

    address public user = address(this); // 測試合約作為執行者

    uint256 public constant AMOUNT_IN = 1e18; // 交換輸入代幣數量 (1 DAI)
    uint24 public constant FEE = 3000; // 0.3%

    function setUp() public {
        // Fork Ethereum 主網
        forkId = vm.createFork('https://mainnet.infura.io/v3/db89e26032c74df59ba1363e3c3979e9');
        vm.selectFork(forkId);

        // 初始化 Uniswap V3 Router 地址 (Mainnet)
        router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

        // 初始化代幣地址 (Mainnet)
        tokenIn = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // DAI
        tokenOut = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48); // USDC

        // 給測試合約分配 DAI
        deal(address(tokenIn), user, AMOUNT_IN);
    }

    function testSwapExactInputSingle() public {
        // 檢查測試合約的初始餘額
        uint256 initialTokenOutBalance = tokenOut.balanceOf(user);

        // Approve Router 合約使用 DAI
        tokenIn.approve(address(router), AMOUNT_IN);

        // 構造交換參數
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter.ExactInputSingleParams({
            tokenIn: address(tokenIn),
            tokenOut: address(tokenOut),
            fee: FEE,
            recipient: user,
            deadline: block.timestamp + 1 hours,
            amountIn: AMOUNT_IN,
            amountOutMinimum: 0, // 不設最小輸出，接受任意數量
            sqrtPriceLimitX96: 0 // 不設價格限制
        });

        // 執行交換
        uint256 amountOut = router.exactInputSingle(params);

        // 打印交換結果
        console.log('TokenOut Received:', amountOut);

        // 檢查交換後的餘額變化
        uint256 finalTokenOutBalance = tokenOut.balanceOf(user);
        assertEq(finalTokenOutBalance, initialTokenOutBalance + amountOut);

        // 確保輸出數量大於 0
        assertGt(amountOut, 0);
    }
}
