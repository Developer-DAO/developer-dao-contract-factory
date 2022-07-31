require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
 solidity: "0.8.9",
 networks: {
   matic: {
     url: `https://polygon-mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`,
     accounts: [process.env.PRI_KEY]
   },
   rinkeby: {
     url: `https://rinkeby.infura.io/v3/${process.env.INFURA_API_KEY}`,
     accounts: [process.env.PRI_KEY]
   },
 },
 etherscan: {
   apiKey: process.env.POLYGONSCAN_API_KEY,
 },
 settings: {
   optimizer: {
     enabled: true,
     runs: 200,
   },
 },
};
