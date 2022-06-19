import { ethers } from "hardhat";
const hre = require("hardhat");

async function main() {
  // Fetch the provider.
  const { provider } = ethers;

  const estimateGasPrice = await provider.getGasPrice();
  console.log(
    `Gas Price: ${ethers.utils.formatUnits(estimateGasPrice, "gwei")} gwei`
  );

  const governance = "0x6357EDbfE5aDA570005ceB8FAd3139eF5A8863CC";
  const fund = "0x6bfc9DB28f0A6d11a8d9d64c86026DDD2fad293B";
  const token = "0x8cc0f052fff7ead7f2edcccac895502e884a8a71";
  const fee = 1000; // 0.1%

  // Fetch the wallet accounts.
  const [operator] = await ethers.getSigners();

  // // Fetch contract factories.
  // const Factory = await ethers.getContractFactory("ARTHFlashMinter");
  // const contract = await Factory.connect(operator).deploy(
  //   token,
  //   fund,
  //   governance,
  //   fee
  // );

  // console.log(`\n Contract details: `);
  // console.log(` - New contract at address(${contract.address})`);

  // await contract.deployed();

  await hre.run("verify:verify", {
    address: "0xc4bBeFDc3066b919cd1A6B5901241E11282e625D",
    constructorArguments: [token, fund, governance, fee],
  });
}

main().catch(console.error);
