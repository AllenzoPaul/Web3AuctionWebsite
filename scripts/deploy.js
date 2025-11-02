const hre = require("hardhat");

async function main() {
  console.log("Deploying SimpleAuction contract...");

  const SimpleAuction = await hre.ethers.getContractFactory("SimpleAuction");
  
  // Deploy with parameters
  const auction = await SimpleAuction.deploy(
    "Vintage Laptop",                    // itemName
    hre.ethers.parseEther("1"),         // minimumBid (1 ETH) - Updated syntax
    60                                   // durationMinutes
  );

  await auction.waitForDeployment();    // Updated from .deployed()

  const address = await auction.getAddress();  // Get address
  console.log("✅ Contract deployed to:", address);
  console.log("\n🔑 SAVE THIS ADDRESS!");
  console.log("Contract Address:", address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });