const MlPlatform = artifacts.require("MlPlatform");

contract("MlPlatform", accounts => {
    const [deployer, oracle, client1, client2, newOwner] = accounts;
    let mlPlatformInstance;

    before(async () => {
        // Deploy the contract with the initial setup
        mlPlatformInstance = await MlPlatform.new(
            oracle, // oracle address
            deployer, // contract owner
            "initialModelAddress", // model address
            "testDataHash", // test data hash
            "testDataLabelHash", // test data label hash
            { from: deployer, value: web3.utils.toWei("1", "ether") } // funding the reward pool
        );
    });

    it("should set initial contract state correctly", async () => {
        const oracleAddress = await mlPlatformInstance.oracleAddress();
        const contractOwner = await mlPlatformInstance.contractOwner();
        const rewardPool = await mlPlatformInstance.rewardPool();

        assert.equal(oracleAddress, oracle, "Oracle address is incorrect");
        assert.equal(contractOwner, deployer, "Contract owner is incorrect");
        assert.equal(rewardPool.toString(), web3.utils.toWei("1", "ether"), "Reward pool is incorrect");
    });

    it("should allow clients to submit weights", async () => {
        await mlPlatformInstance.submitWeights("weightsAddress1", { from: client1 });
        const clientId1 = await mlPlatformInstance.addressToClientId(client1);

        assert(clientId1.toNumber() > 0, "Client1 was not added correctly");

        await mlPlatformInstance.submitWeights("weightsAddress2", { from: client2 });
        const clientId2 = await mlPlatformInstance.addressToClientId(client2);

        assert(clientId2.toNumber() > 0, "Client2 was not added correctly");
    });

    it("should start evaluation after the submission period", async () => {
        // Fast-forward blocks to simulate time passing
        await advanceBlocks(11);

        // This part requires the oracle to be listening and to respond,
        // which is outside the scope of this direct testing example.
        // You would need an off-chain component to listen for events and call `provideData`.
        // For testing, you might simulate this call directly:
        await mlPlatformInstance.provideData(1, "updatedModelAddress", [1, 2], [10, 20], [5, 15], { from: oracle });

        const updatedModelAddress = await mlPlatformInstance.modelAddress();
        assert.equal(updatedModelAddress, "updatedModelAddress", "Model address was not updated correctly");
    });

    // Additional tests can simulate more interactions and check contract states
});

// Helper function to advance blocks
async function advanceBlocks(numberOfBlocks) {
    for (let i = 0; i < numberOfBlocks; i++) {
        await web3.currentProvider.send({
          jsonrpc: '2.0',
          method: 'evm_mine',
          id: new Date().getTime()
        }, () => {});
    }
}
