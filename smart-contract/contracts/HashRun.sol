// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract HashRun is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address private oracle; // Address of the Chainlink Oracle
    bytes32 private jobId; // The job ID
    uint256 private fee; // Fee for the Chainlink request

    address public ownerAddress;
    address public flowstakeAddress; // Address of the beneficiary
    string public challengeStatus = 'ongoing';
    uint public totalDonation = 0;
    mapping(address => uint) public donorsDonations;
    bool public paused = false;

    // Define events for logging
    event LogChallengeStarted(address deployerAddress);
    event LogNewDonation(address donorAddress, uint donationAmount, uint totalDonation);
    event LogChallengeStatusRefreshed(string latestStatus);
    // Additional events for HashRun...

    constructor(address _flowstakeAddress, address _oracle, bytes32 _jobId, uint256 _fee) {
        setPublicChainlinkToken(); // Initialize the Chainlink Token
        ownerAddress = msg.sender;
        flowstakeAddress = _flowstakeAddress;
        oracle = _oracle; // Set the Chainlink Oracle address
        jobId = _jobId; // Set the job ID for the Chainlink request
        fee = _fee; // Set the LINK fee for the request
        emit LogChallengeStarted(msg.sender);
    }

    // Chainlink request to update the challenge status
    function refreshChallengeStatus(string memory url, string memory path) public onlyOrganizers whenOngoing {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        request.add("get", url); // Set the URL for the GET request
        request.add("path", path); // Set the path to extract data from the JSON response
        sendChainlinkRequestTo(oracle, request, fee); // Send the request
    }

    // Callback function for the Chainlink oracle response
    function fulfill(bytes32 _requestId, bytes32 _status) public recordChainlinkFulfillment(_requestId) {
        challengeStatus = bytes32ToString(_status); // Update the challenge status based on the oracle response
        emit LogChallengeStatusRefreshed(challengeStatus);
    }

    // Helper function to convert bytes32 to string
    function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
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

    // Implement additional functionalities as needed...
}
