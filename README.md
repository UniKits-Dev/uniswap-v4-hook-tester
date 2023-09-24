## uniswap-v4-hook-tester

This is a template with PoolManagerTester Contract that can help you trigger hooks for Swap or ModififyPosition operation.

Uniswap v4 uses `lock` function to tigger the swap and modify position operation. `lockAcquired` will be invoked after the lock is executed. 

In this case, a contract is necessary to be built to execute the on-chain operation for uniswap-v4. `uniswap-v4-hook-tester` provided a simple and easy-to-use template to have a quick test for the created pool.

## Usage 

```bash
forge build

```


### Thanks

* [v4-template](https://github.com/saucepoint/v4-template)
* [uniswap-v4-custom-pool](uniswap-v4-custom-pool)


