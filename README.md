# ARTH Flashloans

This repository contains information on how to use ARTH's flashloans on Polygon, BSC. Borrow an unlimited amount of ARTH for a fee of 0.1%

| Network             | Deployed Lender Address                                                                                                  |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| Polygon             | [0x9A9c25D9e304ddb284e5a36bE0cdEE0a58Ac3C04](https://polygonscan.com/address/0x9A9c25D9e304ddb284e5a36bE0cdEE0a58Ac3C04) |
| Binance Smart Chain | [0x91aBAa2ae79220f68C0C76Dd558248BA788A71cD](https://bscscan.com/address/0x91aBAa2ae79220f68C0C76Dd558248BA788A71cD)     |

## How to create a flashloan?

Check out the [FlashLoanExample.sol](./contracts/FlashLoanExample.sol) for an implementation of how the flash loans work. You can deploy the script
using [deploy-example.ts](./scripts/deploy-example.ts).

```
# eg: to deploy on the BSC chain
hardhat run ./scripts/deploy-example.ts --network bsc
```
