## uniswap-v4-hook-tester

This is a template with PoolManagerTester Contract that can help you trigger hooks for Swap or ModififyPosition operation.

Uniswap v4 uses `lock` function to tigger the swap and modify position operation. `lockAcquired` will be invoked after the lock is executed. 

In this case, a contract is necessary to be built to execute the on-chain operation for uniswap-v4. `uniswap-v4-hook-tester` provided a simple and easy-to-use template to have a quick test for the created pool.

## Usage 

```bash
forge build
forge script script/DeployAndRun.s.sol  --broadcast --fork-url http://localhost:8545 --code-size-limit 300000 -vvvvv
```

## Basis

```
PoolKey memory keyToAdd = PoolKey({
  currency0: currency0,
  currency1: currency1,
  fee: 3000,
  hooks: IHooks(address(lensAuthHook)),
  tickSpacing: 1
});

PoolManagerTester tester = new PoolManagerTester(address(poolManager), keyToAdd);

//modifyPosition
tester.runMP(73781, 74959, 1 ether); // 1600 1800

// Swap
tester.runSwap(true, 100, SQRT_RATIO_1_1);
```

### Thanks

* [v4-template](https://github.com/saucepoint/v4-template)
* [uniswap-v4-custom-pool](uniswap-v4-custom-pool)


