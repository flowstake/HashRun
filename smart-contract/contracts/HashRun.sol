// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Assuming Chainlink is used as a replacement for Oraclize
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract CryptoRun is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    address public ownerAddress;
    address public beCodeAddress;
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
    // Additional events...

    modifier onlyOrganizers {
        require(msg.sender == ownerAddress || msg.sender == beCodeAddress, "Caller is not an organizer");
        _;
    }

    modifier onlyOracle() {
        // This modifier implementation would change based on the chosen oracle solution
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

    constructor(address _beCodeAddress) {
        ownerAddress = msg.sender;
        beCodeAddress = _beCodeAddress;
        // Chainlink setup
        setPublicChainlinkToken();
        jobId = "YourJobIdHere"; // Set your job ID here
        fee = 0.1 * 10 ** 18; // 0.1 LINK
        emit LogChallengeStarted(msg.sender);
    }

    receive() external payable whenOngoing whenNotPaused {
        require(msg.value > 0, "No value sent");
        donorsDonations[msg.sender] += msg.value;
        totalDonation += msg.value;
        emit LogNewDonation(msg.sender, msg.value, totalDonation);
    }

    // Function to request data from the oracle
    function refreshChallengeStatus() public onlyOrganizers whenOngoing {
        // Chainlink request setup...
    }

    // Callback function used by Chainlink nodes
    function fulfill(bytes32 _requestId, string memory _result) public recordChainlinkFulfillment(_requestId) {
        // Process the result...
    }

    // Withdrawal and other contract functions...

    function pause() public onlyOrganizers whenNotPaused {
        paused = true;
        emit LogPause();
    }

    function unpause() public onlyOrganizers {
        paused = false;
        emit LogUnpause();
    }
}
