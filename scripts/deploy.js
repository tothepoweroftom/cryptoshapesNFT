
// You always want to use run.js to just make sure stuff is working locally and not crashing. It's your own little playground!
const main = async () => {
    const nftContractFactory = await hre.ethers.getContractFactory('ImageGenerator');
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);
  
    // Call the function.
    let txn = await nftContract.generateNewImage()
    // Wait for it to be mined.
    await txn.wait()
  
  
  
  };
  
  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();