import { ethers } from "hardhat";

async function main() {
  const staking = await ethers.getContractFactory("staking");
  console.log("Deploying Contract");

  const stakingContract = await staking.deploy();
  await stakingContract.deployed();

  console.log("staking deployed to :", stakingContract.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
