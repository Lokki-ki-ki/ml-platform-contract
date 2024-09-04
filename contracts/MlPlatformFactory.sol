// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./MlContract.sol";

contract MlPlatformFactory {
    // Record the deployed MlPlatforms
    address public platformOwner;
    address public oracleAddress = 0xAc6c80B1AFb4F2a4B1E663D58EC3332F8780e0a2; // For loacl testnet environment TODO: Change for testnet
    uint256 public contractCount = 0;
    uint256 public startBlock;
    mapping(address => uint256[]) public ownerToContractList;
    mapping(uint256 => address) public idToContract;
    mapping(address => uint256) public contractToIndex;

    // Initialize the contract which will set the 
    constructor() {
        platformOwner = msg.sender;
        startBlock = block.number;
    }

    // Modifiers to used
    modifier onlyOwner() {
        require(msg.sender == platformOwner, "Only the contract owner can call this function.");
        _;
    }

    // Event to emit when a new MlPlatform is created for off-chain Oracle to listen to
    event MlPlatformCreated(address owner, address mlPlatformAddress, uint256 contractId, uint256 ddlTimestamp, uint256 depositRequired);

    // Function to create a new MlPlatform
    function createMlPlatform(
        string memory _modelAddress,
        string memory _testDataHash,
        string memory _testDataLabelHash,
        uint256 _timestamp,
        uint256 _depositRequired
    ) public payable {
        require(msg.value >= 10000, "Please put enough reward.");
        require(_timestamp >= block.timestamp, "Please put a valid ddl timestamp.");
        MlContract newContract = (new MlContract){ value : msg.value }(oracleAddress, msg.sender, _modelAddress, _testDataHash, _testDataLabelHash, _timestamp, _depositRequired);
        address contractAdd = address(newContract);
        contractCount++;
        ownerToContractList[msg.sender].push(contractCount);
        idToContract[contractCount] = contractAdd;
        contractToIndex[contractAdd] = contractCount;
        emit MlPlatformCreated(msg.sender, contractAdd, contractCount, _timestamp, _depositRequired);
    }

    function transferPlatformOwnership(address _newOwner) public onlyOwner {
        platformOwner = _newOwner;
    }

    function getContractList(address _owner) public view returns (uint256[] memory) {
        return ownerToContractList[_owner];
    }
}
