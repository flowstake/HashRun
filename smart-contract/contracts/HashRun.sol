// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract HashRun is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address public ownerAddress;
    address public flowstakeAddress; // Address of the beneficiary
    string public challengeStatus = 'ongoing';
    uint public totalDonation = 0;
    mapping(address => uint) public donorsDonations;
    bool public paused = false;

    // Chainlink specifics
    bytes32 private jobId;
    uint256 private fee;

    // Events
    event LogChallengeStarted(address deployerAddress);
    event LogNewDonation(address donorAddress, uint donationAmount, uint totalDonation);
    event LogChallengeStatusRefreshed(string latestStatus);
    // Additional events for HashRun...

    modifier onlyOrganizers {
        require(msg.sender == ownerAddress || msg.sender == flowstakeAddress, "Caller is not an organizer");
        _;
    }

    modifier onlyOracle() {
        // Placeholder for oracle-specific validation
        _;
    }

    modifier whenOngoing {
        require(keccak256(bytes(challengeStatus)) == keccak256(bytes('ongoing')), "Challenge is not ongoing");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address _flowstakeAddress) {
        ownerAddress = msg.sender;
        flowstakeAddress = _flowstakeAddress;
        // Chainlink setup
        setPublicChainlinkToken();
        jobId = "YourJobIdHere"; // Configure with your actual job ID
        fee = 0.1 * 10 ** 18; // Fee for the Chainlink network (0.1 LINK)
        emit LogChallengeStarted(msg.sender);
    }

    receive() external payable whenOngoing whenNotPaused {
        require(msg.value > 0, "No value sent");
        donorsDonations[msg.sender] += msg.value;
        totalDonation += msg.value;
        emit LogNewDonation(msg.sender, msg.value, totalDonation);
    }

    // Chainlink request to update the challenge status
    function refreshChallengeStatus() public onlyOrganizers whenOngoing {
        // Implementation for triggering a Chainlink oracle request
    }

    // Callback function for the Chainlink oracle response
    function fulfill(bytes32 _requestId, string memory _result) public recordChainlinkFulfillment(_requestId) {
        // Handling the oracle's response
    }

    // Additional functions for managing donations, withdrawals, pausing, and unpausing...

    function pause() public onlyOrganizers whenNotPaused {
        paused = true;
        emit LogPause();
    }

    function unpause() public onlyOrganizers {
        paused = false;
        emit LogUnpause();
    }
}
