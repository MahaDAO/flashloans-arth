# ARTH Flashloans

This repository contains information on how to use ARTH's flashloans on Polygon, BSC. Borrow an unlimited amount of ARTH for a fee of 0.1%

| Network  | Deployed Lender Address                                                                                               |
| -------- | --------------------------------------------------------------------------------------------------------------------- |
| Ethereum | [0xc4bBeFDc3066b919cd1A6B5901241E11282e625D](https://etherscan.io/address/0xc4bBeFDc3066b919cd1A6B5901241E11282e625D) |

## How to create a flashloan?

Check out the [FlashLoanExample.sol](./contracts/FlashLoanExample.sol) for an implementation of how the flash loans work. You can deploy the script
using [deploy-example.ts](./scripts/deploy-example.ts).

```
# eg: to deploy on the BSC chain
hardhat run ./scripts/deploy-example.ts --network bsc
```
