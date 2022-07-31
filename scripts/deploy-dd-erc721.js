const { ethers, upgrades } = require("hardhat");

async function main() {
  const DDERC721 = await ethers.getContractFactory("DDERC721");

  const ddERC721 = await upgrades.deployProxy(
    DDERC721,
    [
      "PROXY COLLECTION",
      "PXYC",
      "0x7ea1Bb15c6D91827a37697c75b2Eeee930c0C188",
      "https://ipfs.io/ipfs/QmRMAgDjimQ75aPoXBFHXS9mEa5d9Df6NkZJQQc24N8kU4?filename=contract-data.json",
      "0x58807baD0B376efc12F5AD86aAc70E78ed67deaE",
    ],
    {
      constructorArgs: ["0x300c8f0e2472EB5b17FbA6aF1b654eB65f12A980"],
      unsafeAllow: ["constructor"],
    }
  );
  await ddERC721.deployed();

  console.log(`ddERC721 deployed to: ${ddERC721.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
