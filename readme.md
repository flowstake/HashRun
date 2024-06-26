# HashRun Solidity Contract

## Overview

The HashRun contract is a Solidity-based smart contract designed for Ethereum networks, leveraging Chainlink oracles to interact with off-chain data. It is particularly aimed at managing charitable challenges, where donations are collected until a certain challenge is met. The status of the challenge (e.g., "ongoing", "accomplished", "failed") is determined through data fetched from external APIs via Chainlink oracles. This contract allows for donations to be made directly to the contract and provides mechanisms for funds withdrawal by the beneficiary or donors, depending on the outcome of the challenge.

## Features

- **Donation Management**: Collects and tracks donations towards a challenge.
- **Oracle Integration**: Utilizes Chainlink oracles for secure and reliable off-chain data retrieval to update the challenge status.
- **Dynamic Challenge Status**: The challenge can be in one of several states, such as "ongoing", "accomplished", or "failed", determined by external data sources.
- **Secure Withdrawals**: Implements withdrawal patterns for both donors (in case of challenge failure) and beneficiaries (upon challenge completion).
- **Pausable**: The contract can be paused and unpaused by the owner, providing a mechanism to stop interactions in case of emergencies or maintenance.

## Contract Functions

### Constructor
Initializes the contract with the necessary parameters for Chainlink oracle requests and sets the beneficiary address.

### `receive()`
Accepts Ether donations sent to the contract.

### `refreshChallengeStatus(string memory url, string memory path)`
Triggers a Chainlink oracle request to update the challenge status based on data from an external API.

### `fulfill(bytes32 _requestId, bytes32 _status)`
A callback function used by Chainlink oracles to return the challenge status.

### `pause()`
Allows the contract owner to pause the contract.

### `unpause()`
Allows the contract owner to unpause the contract.

### `withdrawDonation()`
Enables donors to withdraw their donations if the challenge fails.

### `transferFunds()`
Transfers the total donations to the beneficiary upon successful challenge completion.

## Modifiers

- **`onlyOwner`**: Restricts function access to the contract owner.
- **`whenNotPaused`**: Ensures that interactions are only allowed when the contract is not paused.

## Events

- **`LogChallengeStarted`**: Emitted when the contract is deployed.
- **`LogNewDonation`**: Emitted upon receiving a new donation.
- **`LogChallengeStatusRefreshed`**: Indicates the challenge status has been updated.
- **`LogPaused`** and **`LogUnpaused`**: Signal the pausing and unpausing of the contract.
- **`LogDonationWithdrawn`**: Emitted when a donor withdraws their donation.
- **`LogFundsTransferred`**: Emitted when funds are transferred to the beneficiary.

## Development and Deployment

### Prerequisites

- Solidity ^0.8.0
- Chainlink contracts

### Setup and Deployment

1. **Configure Environment**: Set up a development environment with Truffle or Hardhat to compile and deploy the contract.
2. **Deploy Contract**: Deploy the `HashRun` contract to an Ethereum network. Provide the constructor parameters, including the beneficiary address, Chainlink oracle address, job ID, and fee.
3. **Verify Contract**: After deployment, verify the contract on Etherscan for transparency and interaction.

## Security Considerations

- **Reentrancy Guard**: Uses the Checks-Effects-Interactions pattern to prevent reentrancy attacks.
- **Chainlink Oracles**: Relies on Chainlink for secure and reliable off-chain data fetching.
- **Ownership and Pausability**: Implement ownership and pausable features to manage and mitigate potential issues or attacks.

This contract represents a foundational structure for blockchain-based charitable initiatives, emphasizing transparency, security, and reliability through the integration of Chainlink oracles for off-chain data interaction.

# HashRun Contract with Chainlink Integration

## Overview

The HashRun smart contract is designed to manage a donation-driven challenge, leveraging the Chainlink network to interact with external data sources. This contract facilitates the collection of donations, tracking the progress of a challenge based on data from Strava, and distributing the funds to a beneficiary upon successful completion of the challenge. It employs Chainlink Oracles for secure and reliable data retrieval from Strava, ensuring the integrity and automation of challenge status updates.

## Features

- **Donation Management**: Users can send ETH as donations to the contract. These donations contribute towards the challenge's funding goal.
- **Challenge Status**: Utilizes Chainlink Oracles to fetch the latest status of a specific activity from Strava (e.g., a running or cycling event). The status determines whether the challenge is ongoing, accomplished, or failed.
- **Funds Distribution**: Upon successful completion of the challenge (as verified through Strava data), the contract automatically transfers the accumulated donations to the designated beneficiary.
- **Withdrawal Functionality**: Donors have the ability to withdraw their donations if the challenge fails or is canceled.
- **Pausable Contract**: The contract owner can pause and unpause the contract to temporarily halt donations and withdrawals for maintenance or emergency purposes.

## Technical Summary

### Contract Initialization

Upon deployment, the contract is initialized with the following parameters:
- `flowstakeAddress`: The beneficiary's address that will receive the funds upon successful completion of the challenge.
- `oracle`: The address of the Chainlink Oracle that will fetch the activity status from Strava.
- `jobId`: A unique identifier for the Chainlink job that specifies the task to be performed by the Oracle.
- `fee`: The LINK token fee to be paid to the Oracle for data retrieval services.

### Donation Process

ETH donations are accepted through the contract's fallback function. Each donation is logged, and the total donation amount is updated accordingly.

### Challenge Status Update

The contract owner can initiate a status update request to Chainlink Oracles, specifying the URL and path to the desired Strava activity. The Oracle fetches the activity status from Strava and returns the data to the contract through the `fulfill` callback function. Based on the response, the contract updates the challenge's status accordingly.

### Withdrawals and Fund Transfers

Donors can withdraw their donations if the challenge fails. Upon successful completion of the challenge, the contract owner triggers the transfer of the total collected donations to the beneficiary's address.

### Contract Pause/Unpause

The contract can be paused or unpaused by the owner to temporarily disable donation and withdrawal functionalities. This feature provides an additional layer of control and security.

### Strava Activity Example

For demonstration purposes, the contract is configured to reference a specific Strava activity:
- Strava Activity URL: [https://www.strava.com/activities/10037054514](https://www.strava.com/activities/10037054514)

The contract utilizes this URL to verify the completion status of the activity through Chainlink Oracles, determining the outcome of the associated challenge.

### Security Considerations

The contract implements checks-effects-interactions patterns to mitigate reentrancy attacks, especially in withdrawal functions. Additionally, the use of Chainlink Oracles ensures the reliability and tamper-proof nature of the external data fetched from Strava.

## Deployment and Usage

To deploy and use the HashRun contract, ensure you have a funded Ethereum wallet with ETH for deployment and LINK tokens for paying Oracle fees. Compile and deploy the contract using Remix, Hardhat, or Truffle, providing the necessary constructor parameters. Interact with the contract through Ethereum wallet interfaces or programmatically using Web3 libraries.

For further details on Chainlink Oracles and job specifications, refer to the Chainlink documentation.

# Cryptorun Back - Original Documentation

[UPDATE: the challenge is over! 65KM have been run, and 1.85 ETH have been collected :) Thanks to all!]

This is the back-end engine of the [Cryptorun challenge](https://cryptorun.brussels). The goal of this challenge is for Thomas Vanderstraeten to run 60km around Brussels to raise funds and awareness for BeCode.

The catch: funds will be collected in crypto-currency using ETH, and the GPS of Thomas will be connected to the Blockchain!

You can find detailed explanation of the code behind this challenge on this [general blog article](https://medium.com/@vanderstraeten.thomas/a-crypto-fundraising-for-a-charity-on-the-ethereum-net-with-a-strava-gps-oracle-8a24167c1dad). Please also consult this [blog article dedicated to testing](https://medium.com/@vanderstraeten.thomas/testing-the-cryptorun-smart-contract-a-tale-of-obsessive-perfection-84ded25f1636) of the contract.

Special thanks to [Hannes](https://github.com/jebuske) for his kind review and suggestions!

## Architecture

### Overview
![alt text](https://s3.eu-central-1.amazonaws.com/cryptorun.be/cryptorun-architecture.png "Back-end architecture")

### Smart contract
The smart contract lives at address 0x7ad38438b15338f6d1846961903055ada6fff054, it can be consulted [here on Etherscan](https://etherscan.io/address/0x7ad38438b15338f6d1846961903055ada6fff054). NOTE THAT IT IS NOW CLOSED TO ANY DONATIONS!

### Oracle (Strava connection)
The Oracle in charge of connecting with Strava runs on AWS Lambda with a Python 2.7 runtime.

### Test Oracle
A exceedingly simple dummy Oracle for the Truffle test suite. This Lambda has the same interface as the real Oracle, but the status that it returns can easily be switched as it is read from an environment variable. We use the aws-cli to directly update this environment variable during the tests, to fake the evolution of the challenge status.

## Testing the smart contract

We use Truffle to perform all tests. Once you're done with the below setup, just run `truffle test test/cryptoRun.js` and enjoy the show.

### Importing the Oraclize contract

Note that since Truffle cannot read the Oraclize.sol file directly from GitHub, we have to import this contract locally and source it accordingly in the CryptoRun contract import statement (we use the version available [here](https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.4.sol)). It is important that the Oraclize contract is named `usingOraclize.sol` so that Truffle knows it's this one that must be imported.

### Launching a local test Blockchain

Make sure you have `ganache-cli` installed. Then run in a daemon window
```
ganache-cli --defaultBalanceEther 1000000 --mnemonic "test blockchain"
```
Note that the mnemonic option will ensure that it's always the same addresses that will be generated, which is require so we don't have to constantly update the OAR in the Ethereum Bridge setup (see further).

### Setting up the Ethereum Bridge
After ganache has been started, make sure you have Ethereum Bridge installed. For this, clone locally the [repo available here](https://github.com/oraclize/ethereum-bridge), then run `npm install`. You can then run the following command in a daemon window
```
node bridge -H localhost:8545 -a 9
```
Wait for the bridge to load (long and verbose). After it's done, it should instruct you to put the following line in the Oraclized smart contract constructor:
```
OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
```
Note that the actual address might vary. Sometimes there might be issue with the Bridge warning that it has already see specific Tx IDs - this is due to incompatibilites with latest solc versions. In that case just delete everything within the ethereum-bridge/database/tingodb folder.

### Setting up AWS
Make sure you have the correct access rights to modify the test Lambda for the Oracle - this will be needed for the forced refreshed during the tests.

## Deployment checklist

Before deploying, do make sure to have removed the following lines from the contract used for testing:

### Import statement
The below line
```
import "./usingOraclize.sol";
```
must be replaced by
```
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
```

### OAR in the constructor
The below line should be completely removed from the contract constructor function
```
OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
```

### Oraclize endpoint
The below line
```
oraclize_query("URL", "json(https://pgy2ax76f9.execute-api.eu-central-1.amazonaws.com/test/CryptoRunTest).challenge_status");
```
must be replaced by
```
oraclize_query("URL", "json(https://pgy2ax76f9.execute-api.eu-central-1.amazonaws.com/prod/CryptoRun).challenge_status");
```

### Flowstake address
The address of Flowstake must be specified as a constructor parameter when the contract is first deployed.
