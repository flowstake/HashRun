// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract HashRun is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    address public ownerAddress;
    address public flowstakeAddress;
    string public challengeStatus = 'ongoing';
    uint public totalDonation = 0;
    mapping(address => uint) public donorsDonations;
    bool public paused = false;

    event LogChallengeStarted(address deployerAddress);
    event LogNewDonation(address donorAddress, uint donationAmount, uint totalDonation);
    event LogChallengeStatusRefreshed(string latestStatus);
    event LogDonationWithdrawn(address donorAddress, uint withdrawalAmount);
    event LogFundsTransferred(address beneficiaryAddress, uint amount);
    event LogPaused();
    event LogUnpaused();

    modifier onlyOrganizers {
        require(msg.sender == ownerAddress || msg.sender == flowstakeAddress, "Caller is not an organizer");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract is paused");
        _;
    }

    constructor(address _flowstakeAddress, address _oracle, bytes32 _jobId, uint256 _fee) {
        setPublicChainlinkToken();
        ownerAddress = msg.sender;
        flowstakeAddress = _flowstakeAddress;
        oracle = _oracle;
        jobId = _jobId;
        fee = _fee;
        emit LogChallengeStarted(msg.sender);
    }

    receive() external payable whenNotPaused {
        require(msg.value > 0, "No value sent");
        donorsDonations[msg.sender] += msg.value;
        totalDonation += msg.value;
        emit LogNewDonation(msg.sender, msg.value, totalDonation);
    }

    function refreshChallengeStatus(string memory url, string memory path) public onlyOrganizers whenNotPaused {
        // Chainlink request logic here...
    }

    function fulfill(bytes32 _requestId, bytes32 _status) public recordChainlinkFulfillment(_requestId) {
        challengeStatus = bytes32ToString(_status);
        emit LogChallengeStatusRefreshed(challengeStatus);
    }

    function withdrawDonations() public whenNotPaused {
        require(keccak256(bytes(challengeStatus)) == keccak256(bytes("failed")), "Challenge not failed");
        uint donationAmount = donorsDonations[msg.sender];
        require(donationAmount > 0, "No donations to withdraw");

        donorsDonations[msg.sender] = 0;
        payable(msg.sender).transfer(donationAmount);
        emit LogDonationWithdrawn(msg.sender, donationAmount);
    }

    function transferFundsToBeneficiary() public onlyOrganizers whenNotPaused {
        require(keccak256(bytes(challengeStatus)) == keccak256(bytes("accomplished")), "Challenge not accomplished");
        uint amount = address(this).balance;
        payable(flowstakeAddress).transfer(amount);
        emit LogFundsTransferred(flowstakeAddress, amount);
    }

    function pause() public onlyOrganizers {
        paused = true;
        emit LogPaused();
    }

    function unpause() public onlyOrganizers {
        paused = false;
        emit LogUnpaused();
    }

    function bytes32ToString(bytes32 _bytes32) private pure returns (string memory) {
        // Conversion logic...
    }

    // Additional functionalities as needed...
}
