const MlPlatform = artifacts.require('MlPlatform');
contract('MlPlatform', (accounts) => {
    it('Test submit the weights.', async () => {
        const mlPlatform = await MlPlatform.deployed();
        const weightAddress = "QmXvmaD8FuPnySgNaxv3vun9ZtuMGdDFnNS6tsLKz8Jhyj";
        await mlPlatform.submitWeights(weightAddress, {from: accounts[2]});
        // Check the weights are submitted
        const clientId = await mlPlatform.addressToClientId(accounts[2]);
        const submission = await mlPlatform.clientIdNewSubmission(clientId);
        assert.equal(submission, weightAddress, 'Weights are not submitted');
    });

    it('Test submit the model.', async () => {
        const mlPlatform = await MlPlatform.deployed();
    });
})