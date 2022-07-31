const { ethers, upgrades } = require("hardhat");

async function main() {
  const DDFactory = await ethers.getContractFactory("DDFACTORY");

  const ddFactory = await upgrades.deployProxy(
    DDFactory,
    ["0.0.1", "0xf4F63f716aD56fc8CD23954F09D371ed548fd2C4"],
    {
      constructorArgs: ["0x300c8f0e2472EB5b17FbA6aF1b654eB65f12A980"],
      unsafeAllow: ["constructor"],
    }
  );
  await ddFactory.deployed();

  console.log(`ddFactoryV1: ${ddFactory.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
