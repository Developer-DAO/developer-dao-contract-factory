const { ethers, upgrades } = require("hardhat");

async function main() {
  const Forwarder = await ethers.getContractFactory("Forwarder");

  const minimalForwarder = await upgrades.deployProxy(Forwarder, {
    initializer: "initialize",
  });
  await minimalForwarder.deployed();

  console.log(`Forwarder: ${minimalForwarder.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
