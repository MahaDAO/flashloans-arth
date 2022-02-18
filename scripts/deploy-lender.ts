import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  // Fetch the provider.
  const { provider } = ethers;

  const estimateGasPrice = await provider.getGasPrice();
  console.log(
    `Gas Price: ${ethers.utils.formatUnits(estimateGasPrice, "gwei")} gwei`
  );

  const token = "0xe52509181feb30eb4979e29ec70d50fd5c44d590";
  const fee = 0;

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

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
