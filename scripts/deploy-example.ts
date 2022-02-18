import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  // Fetch the provider.
  const { provider } = ethers;

  const estimateGasPrice = await provider.getGasPrice();
  console.log(
    `Gas Price: ${ethers.utils.formatUnits(estimateGasPrice, "gwei")} gwei`
  );

  const lender = "0x9A9c25D9e304ddb284e5a36bE0cdEE0a58Ac3C04";
  const token = "0xe52509181feb30eb4979e29ec70d50fd5c44d590";

  // Fetch the wallet accounts.
  const [operator] = await ethers.getSigners();

  // Fetch contract factories.
  const Factory = await ethers.getContractFactory("FlashLoanExample");
  const contract = await Factory.connect(operator).deploy(lender, token);

  console.log(`\n Contract details: `);
  console.log(` - New contract at address(${contract.address})`);

  await contract.deployed();

  await hre.run("verify:verify", {
    address: contract.address,
    constructorArguments: [lender, token],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
