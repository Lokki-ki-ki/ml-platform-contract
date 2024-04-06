const MlPlatform = artifacts.require('MlPlatform');
// Test the contract initialization
contract('MlPlatform', (accounts) => {
    it('Test the contract initizalization.', async () => {
        const mlPlatform = await MlPlatform.deployed();
        const oracleAddress = await mlPlatform.oracleAddress();
        const contractOwner = await mlPlatform.contractOwner();
        assert.equal(oracleAddress, accounts[9], 'Oracle address is incorrect');
        assert.equal(contractOwner, accounts[0], 'Contract owner is incorrect');
    });
})
