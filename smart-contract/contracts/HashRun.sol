// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract HashRun is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // State variables
    address private oracle; // Address of the Chainlink Oracle
    bytes32 private jobId; // The job ID for the Chainlink request
    uint256 private fee; // Fee for the Chainlink request

    address public ownerAddress;
    address public flowstakeAddress; // Address of the beneficiary
    string public challengeStatus = 'ongoing';
    uint public totalDonation = 0;
    mapping(address => uint) public donorsDonations;
    bool public paused = false;

    // Events
    event LogChallengeStarted(address deployerAddress);
    event LogNewDonation(address donorAddress, uint donationAmount, uint totalDonation);
    event LogChallengeStatusRefreshed(string latestStatus);
    event LogPaused();
    event LogUnpaused();
    event LogDonationWithdrawn(address donor, uint amount);
    event LogFundsTransferred(address beneficiary, uint amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == ownerAddress, "Caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address _flowstakeAddress, address _oracle, bytes32 _jobId, uint256 _fee) {
        setPublicChainlinkToken(); // Initialize the Chainlink Token
        ownerAddress = msg.sender;
        flowstakeAddress = _flowstakeAddress;
        oracle = _oracle; // Set the Chainlink Oracle address
        jobId = _jobId; // Set the job ID for the Chainlink request
        fee = _fee; // Set the LINK fee for the request
        emit LogChallengeStarted(msg.sender);
    }

    // Allows donations to the contract
    receive() external payable whenNotPaused {
        require(msg.value > 0, "No value sent");
        donorsDonations[msg.sender] += msg.value;
        totalDonation += msg.value;
        emit LogNewDonation(msg.sender, msg.value, totalDonation);
    }

    // Chainlink request to update the challenge status
    function refreshChallengeStatus(string memory url, string memory path) public onlyOwner whenNotPaused {
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

    // Pauses the contract to prevent donations
    function pause() public onlyOwner {
        paused = true;
        emit LogPaused();
    }

    // Unpauses the contract to allow donations
    function unpause() public onlyOwner {
        paused = false;
        emit LogUnpaused();
    }

    // Allows donors to withdraw their donations
    function withdrawDonation() public whenNotPaused {
        uint donationAmount = donorsDonations[msg.sender];
        require(donationAmount > 0, "No donation to withdraw");

        donorsDonations[msg.sender] = 0; // Reset the donation amount before sending to prevent re-entrancy
        (bool sent, ) = msg.sender.call{value: donationAmount}("");
        require(sent, "Failed to send Ether");

        emit LogDonationWithdrawn(msg.sender, donationAmount);
    }

    // Transfer the total donations to the beneficiary (flowstakeAddress)
    function transferFunds() public onlyOwner whenNotPaused {
        uint amount = address(this).balance;
        require(amount > 0, "No funds to transfer");

        (bool sent, ) = flowstakeAddress.call{value: amount}("");
        require(sent, "Failed to send Ether");

        emit LogFundsTransferred(flowstakeAddress, amount);
    }

    // Helper function to convert bytes32 to string
    function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++)
