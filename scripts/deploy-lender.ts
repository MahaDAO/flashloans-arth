import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  // Fetch the provider.
  const { provider } = ethers;

  const estimateGasPrice = await provider.getGasPrice();
  console.log(
    `Gas Price: ${ethers.utils.formatUnits(estimateGasPrice, "gwei")} gwei`
  );

  const token = "0xB69A424Df8C737a122D0e60695382B3Eec07fF4B";
  const fee = 1000; // 0.1%

  // Fetch the wallet accounts.
  const [operator] = await ethers.getSigners();

  // Fetch contract factories.
  const Factory = await ethers.getContractFactory("FlashMinter");
  const contract = await Factory.connect(operator).deploy(token, fee);

  console.log(`\n Contract details: `);
  console.log(` - New contract at address(${contract.address})`);

  await contract.deployed();

  await hre.run("verify:verify", {
    address: contract.address,
    constructorArguments: [token, fee],
  });
}

main().catch(console.error);
