// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { BaseScript } from "./Base.s.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {PoolManagerTester} from "../src/PoolManagerTester.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {MockERC20} from "@uniswap/v4-core/test/foundry-tests/utils/MockERC20.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {Counter} from "../src/Counter.sol";
import {HookDeployer} from "../test/utils/HookDeployer.sol";


contract DeployAndRunScript is BaseScript {
    using CurrencyLibrary for Currency;

    IPoolManager public poolManager;
    
    bytes public constant ZERO_BYTES = new bytes(0);
    uint160 public constant SQRT_RATIO_1_1 = 79228162514264337593543950336;
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    function run() public broadcaster {
        
        // init 
        poolManager = new PoolManager(500000);
        // poolManager = IPoolManager(YOUR_ADDRESS);

        MockERC20 tokenA = new MockERC20("TestA", "TA", 18, 100 ether);
        MockERC20 tokenB = new MockERC20("TestB", "TB", 18, 100 ether);

        Currency currency0 = Currency.wrap(address(tokenA));
        Currency currency1 = Currency.wrap(address(tokenB));
        // Make sure the order is correct
        if (currency0 > currency1) {
            // Swap Currency
            Currency tmp = currency1;
            currency1 = currency0;
            currency0 = tmp;
        }

        uint160 sqrtPriceLimitX96ToSet = 3266570274706945504500000000000;

        // Deploy Hooks
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG | Hooks.BEFORE_MODIFY_POSITION_FLAG
                | Hooks.AFTER_MODIFY_POSITION_FLAG
        );
        bytes memory hookBytecode = abi.encodePacked(type(Counter).creationCode, abi.encode(address(poolManager)));

        (address hookAddressPreCaculated, uint256 salt) = HookDeployer.mineSalt(CREATE2_DEPLOYER, flags, hookBytecode);
        Counter counter = new Counter{salt: bytes32(salt)}(IPoolManager(address(poolManager)));
        require(address(counter) == hookAddressPreCaculated, "DeployAndRunScript: hook address mismatch");

        // Hooks End

        PoolKey memory keyToAdd = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: 3000,
            hooks: IHooks(address(counter)),
            tickSpacing: 1
        });

        // Todo:: check if the pool key already exits
        poolManager.initialize(keyToAdd, sqrtPriceLimitX96ToSet, ZERO_BYTES);

        PoolManagerTester tester = new PoolManagerTester(address(poolManager), keyToAdd);
        tokenA.approve(address(tester), 100 ether);
        tokenB.approve(address(tester), 100 ether);

        // modifyPosition
        tester.runMP(73781, 74959, 1 ether); // 1600 1800
        // Swap
        tester.runSwap(true, 100, SQRT_RATIO_1_1);
    }
}
