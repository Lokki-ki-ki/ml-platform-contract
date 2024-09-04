// const MlPlatform = artifacts.require("MlPlatform");

// module.exports = function(deployer, network, accounts) {
//   // print the accounts
//   console.log(accounts[9]);
//   const _oracleAddress = accounts[9];
//   const _contractOwner = accounts[0];
//   const _testDataHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
//   const _testLabelHash = '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
//   const _modelAddress = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
//   deployer.deploy(MlPlatform, _oracleAddress, _contractOwner, _modelAddress, _testDataHash, _testLabelHash, { value: web3.utils.toWei("1", "ether")});
// };

const MlPlatformFactory = artifacts.require("MlPlatformFactory");
module.exports = function(deployer, network, accounts) {
  // print the accounts
  console.log(accounts[0]);
  console.log(accounts[9]);
  // const _oracleAddress = accounts[9];
  // const _contractOwner = accounts[0];
  // const _testDataHash = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
  // const _testLabelHash = '0xabcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
  // const _modelAddress = '0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef'
  deployer.deploy(MlPlatformFactory, { from : accounts[9] });
  
//   runPythonScript('/Users/lokki/Downloads/FYP/fyp_project/ml-platform-contract/updateFile.py');
};