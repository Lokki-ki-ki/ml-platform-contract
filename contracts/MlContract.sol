// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MlContract {
    address public oracleAddress;
    address public contractOwner;
    uint256 public startBlock;
    string private modelAddress;
    string private testDataHash;
    string private testDataLabelHash;
    uint256 public rewardPool;
    uint256 public contractStatus; // 1: Submission, 2: Evaluation, 3: Completed
    uint256 public clientDeposit;
    uint256 public platformFeePool;
    uint256 public platformFee = 10;

    // Modifiers
    modifier onlyOracle() {
        require(msg.sender == oracleAddress, "Only the oracle can call this function.");
        _;
    }
    modifier onlyOwner() {
        require(msg.sender == contractOwner, "Only the contract owner can call this function.");
        _;
    }
    modifier onlyParticipants() {
        require(msg.sender == oracleAddress || msg.sender == contractOwner || addressToClientId[msg.sender] != 0, "Only the participants can call this function.");
        _;
    }

    modifier onlySubmission() {
        require(contractStatus == 1, "The contract is not in the submission stage.");
        _;
    }

    modifier onlyEvaluation() {
        require(contractStatus == 2, "The contract is not in the evaluation stage.");
        _;
    }

    modifier onlyCompleted() {
        require(contractStatus == 3, "The current round is not completed.");
        _;
    }

    // ********** Initialize Stage **********
    // Initialize the contract with the address of the oracle / model to train / Hash of the test data
    constructor (address _oracleAddress, address _contractOwner, string memory _modelAddress, string memory _testDataHash, string memory _testDataLabelHash, ) payable {
        require(msg.value > 100, "Please put deposite.");
        oracleAddress = _oracleAddress;
        contractOwner = _contractOwner; // 
        modelAddress = _modelAddress;
        testDataHash = _testDataHash;
        testDataLabelHash = _testDataLabelHash;
        startBlock = block.number;
        rewardPool = msg.value; // wei
        clientDeposit = 0;
        contractStatus = 1;
    }

    // Events for off-chain oracles to listen to
    event StartEvent(uint256 requestId, uint256 rewardPool);
    event EndEvent(uint256 requestId);
    event ComputationRequestSingle(uint256 _requestId, uint256 _clientId, string _weightsAddress, uint256 _currentReputation);
    event ComputationRequestTest(uint256 _requestId, string _modelAddress, string _testDataAddress, string _testLabelAddress, string _testDataHash, string _testLabelHash);
    event ComputationProvided(uint256 _requestId);
    event SubmissionDone(uint256 _clientId, string _weightsAddress, uint256 _reputation, uint256 _block);
    event RewardPaid(uint256 _clientId, uint256 _reward);
    event DepositReturned(uint256 _clientId, uint256 _deposit);

    // Mapping to store the data requested by the client
    mapping(uint256 => address) public clientIdToAddress;
    mapping(address => uint256) public addressToClientId;
    mapping(uint256 => string) public clientIdNewSubmission;
    mapping(uint256 => uint256) public clientIdReputation;
    mapping(uint256 => uint256) public clientIdDeposit;

    // Variables
    uint256 public nextRequestId = 1; // For interaction with the oracle
    uint256 public nextClientId = 1; // For interaction with the client

    // ********** Client Submission Stage **********
    // Function for the client to submit their weights
    function submitWeights(string memory weightsAddress) public payable onlySubmission {
        require(msg.value > 100, "Please put deposite at least 100 wei.");
        platformFeePool += platformFee;
        uint256 deposit = msg.value - platformFee;
        clientDeposit += deposit;
        
        // If the client has not submitted before, add them to the mapping
        uint256 clientId;
        if (addressToClientId[msg.sender] == 0) {
            clientIdToAddress[nextClientId] = msg.sender;
            addressToClientId[msg.sender] = nextClientId;
            clientIdReputation[nextClientId] = 100; // Initialize reputation as 1.00
            clientId = nextClientId;
            nextClientId++;
        } else {
            clientId = addressToClientId[msg.sender];
        }
        clientIdDeposit[clientId] = deposit;
        clientIdNewSubmission[clientId] = weightsAddress;
        emit SubmissionDone(clientId, weightsAddress, clientIdReputation[clientId], block.number);
    }

    // ********** Evaluation Stage **********
    // Function to request computation from the oracle
    function startEvaluation(string memory testDataAddress, string memory testDataLabelAddress) public onlyParticipants onlySubmission {
        require(contractStatus == 1, "The contract evaluation stage has been started.");
        if (msg.sender == contractOwner || msg.sender == oracleAddress) {
            require(block.number > startBlock + 10, "The submission period has not ended yet.");
        } else {
            require(block.number > startBlock + 15, "The participants can only call this function after 15 blocks if the owner has not called it.");
            require(addressToClientId[msg.sender] != 0, "Only the client can call this function.");
        }
        contractStatus = 2;
        // Request data from the oracle
        requestDataFromOracle(testDataAddress, testDataLabelAddress);
        
    }

    function requestDataFromOracle(string memory testDataAddress, string memory testDataLabelAddress) private {
        uint256 requestId = nextRequestId;
        emit StartEvent(requestId, rewardPool);
        emit ComputationRequestTest(requestId, modelAddress, testDataAddress, testDataLabelAddress, testDataHash, testDataLabelHash);
        for (uint256 i = 1; i < nextClientId; i++) {
            if (keccak256(bytes(clientIdNewSubmission[i])) != keccak256(bytes(""))) {
                emit ComputationRequestSingle(requestId, i, clientIdNewSubmission[i], clientIdReputation[i]);
                clientIdNewSubmission[i] = ""; // Reset the submission
            }
        }
        emit EndEvent(requestId);
        nextRequestId++;
    }

    // Function for the oracle to provide data
    function provideData(uint256 requestId, string memory newModelAddress, int256[] memory clientIds, int256[] memory clientNewReputations, int256[] memory clientRewards) public onlyOracle onlyEvaluation {
        for (uint256 i = 0; i < clientIds.length; i++) {
            clientIdReputation[uint256(clientIds[i])] = uint256(clientNewReputations[i]);
            if (clientRewards[i] > 0) {
                _payClient(uint256(clientIds[i]), uint256(clientRewards[i]));
            }
        }
        // Update the model address
        modelAddress = newModelAddress;
        emit ComputationProvided(requestId);
        contractStatus = 3;
    }

    // Function to pay single client the reward
    function _payClient(uint256 clientId, uint256 reward) private {
        require(rewardPool >= reward, "Not enough funds in the reward pool.");
        rewardPool -= reward;
        // Test with 1 wei
        payable(clientIdToAddress[clientId]).transfer(reward * 1 wei);
        emit RewardPaid(clientId, reward);
        payable(clientIdToAddress[clientId]).transfer(clientIdDeposit[clientId]);
        clientIdDeposit[clientId] = 0;
        emit DepositReturned(clientId, clientIdDeposit[clientId]);
    }

    // ********** Completion Stage **********
    // Function to start the next round
    function startNextRound() public payable onlyCompleted onlyOwner {
        require(msg.value > 0, "Please put deposite.");
        rewardPool = msg.value;
        contractStatus = 1;
        startBlock = block.number;
    }

    // ********** Other Functions **********
    // Function to update the oracle address
    function setOracleAddress(address _newOracleAddress) public {
        // Restrict this function to the contract owner
        require(msg.sender == contractOwner, "Only the contract owner can call this function.");
        oracleAddress = _newOracleAddress;
    }

    // Function to transfer ownership of the contract
    function transferOwnership(address newOwner) public {
        require(msg.sender == contractOwner, "Only the contract owner can call this function.");
        contractOwner = newOwner;
    }

    //Function to refund the reward pool
    function increaseReward() public payable onlyOwner {
        rewardPool += msg.value;
    }

}
