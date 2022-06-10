import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  // Fetch the provider.
  const { provider } = ethers;

  const estimateGasPrice = await provider.getGasPrice();
  console.log(
    `Gas Price: ${ethers.utils.formatUnits(estimateGasPrice, "gwei")} gwei`
  );

  const lender = "0x91aBAa2ae79220f68C0C76Dd558248BA788A71cD";
  const token = "0xB69A424Df8C737a122D0e60695382B3Eec07fF4B";

  // Fetch the wallet accounts.
  const [operator] = await ethers.getSigners();

  // Fetch contract factories.
  const Factory = await ethers.getContractFactory("ARTHFlashLoanExample");
  const contract = await Factory.connect(operator).deploy(lender, token);

  console.log(`\n Contract details: `);
  console.log(` - New contract at address(${contract.address})`);

  await contract.deployed();

  await hre.run("verify:verify", {
    address: contract.address,
    constructorArguments: [lender, token],
  });
}

main().catch(console.error);
