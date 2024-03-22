// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract usingChainlink is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // Define the Chainlink Job ID and oracle address for your specific task
    bytes32 private jobId;
    address private oracle;
    uint256 private fee;

    // Example: Store the response of an oracle call
    uint256 public oracleResponse;

    constructor() {
        // Set the Chainlink token address for the network (this is for Kovan)
        setPublicChainlinkToken();

        // Specify the address of the Chainlink Oracle and Job ID
        oracle = 0x...; // The oracle address
        jobId = "YourJobId"; // The job ID
        fee = 0.1 * 10 ** 18; // The fee to pay the oracle (e.g., 0.1 LINK for Kovan)
    }

    // Create a Chainlink request to retrieve API data, find the target data
    function requestOracleData(string memory url, string memory path) public returns (bytes32 requestId) {
        Chainlink.Request memory request = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        // Set the URL to perform the GET request on
        request.add("get", url);
        
        // Set the path to find the desired data in the API response
        request.add("path", path);

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // Callback function to receive the response
    function fulfill(bytes32 _requestId, uint256 _response) public recordChainlinkFulfillment(_requestId) {
        oracleResponse = _response;
    }

    // Function to withdraw LINK (in case you want to withdraw the LINK from the contract)
    function withdrawLink() external {
        require(LINK.transfer(msg.sender, LINK.balanceOf(address(this))), "Unable to transfer");
    }

    // Additional functions and logic as per your contract's requirements
}
