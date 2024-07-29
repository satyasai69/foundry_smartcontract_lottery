# Lottery Smart Contract

This repository contains a Lottery Smart Contract built with Solidity, deployed using Foundry, and integrated with Chainlink Automation and VRF 2.0 for random number generation and automated contract interactions.

## Prerequisites

Before you begin, ensure you have the following installed:

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Node.js](https://nodejs.org/) and npm
- [Chainlink](https://docs.chain.link/)

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-repo/lottery-smart-contract.git
   cd lottery-smart-contract
   ```

2. **Install Foundry**

   Follow the [official Foundry installation guide](https://book.getfoundry.sh/getting-started/installation).

3. **Install Node.js or foundry dependencies**

   ```bash
   npm install
   ```

   ```bash
   make install
   ```

## Smart Contract Overview

The Lottery Smart Contract allows users to participate in a lottery by sending a fixed amount of ETH. The contract uses Chainlink VRF 2.0 to generate a random winner and Chainlink Automation for automated execution of the lottery process.

## Deployment

1. **Compile the contract**

   ```bash
   forge build
   ```

2. **Deploy the contract**

   Update the `scripts/deploy.js` file with your deployment parameters and run:

   ```bash
   forge script script/DepolyRaffle.s.sol:DepolyRaffle --rpc-url ${SEPOLIA_RPC_URL} --account myaccount --broadcast --verify  --etherscan-api-key ${ETHERSCAN_API_KEY} -vvv
   ```

   or

   ```bash
   make depoly-sepolia
   ```

   Replace `<chain-id>` with the appropriate chain ID for your network.

3. **Verify the contract**

   ```bash
   forge verify-contract --chain-id <chain-id> --contract-address <contract-address> --contract-name <contract-name>
   ```

   Replace `<contract-address>` with the deployed contract address and `<contract-name>` with the contract name.

## Chainlink Integration

### VRF 2.0

To use Chainlink VRF 2.0 for random number generation:

1. Fund your subscription ID with LINK tokens.
2. Update the contract with your VRF subscription ID and key hash.

### Automation

To automate the lottery process using Chainlink Automation:

1. Create an Automation Upkeep for your contract.
2. Configure the Upkeep interval and fund it with LINK tokens.

## Usage

1. **Participate in the Lottery**

   Users can participate by sending the fixed ETH amount to the contract.

   ```solidity
   function enterLottery() public payable {
       require(msg.value == LOTTERY_FEE, "Incorrect ETH amount sent!");
       players.push(msg.sender);
   }
   ```

2. **Draw the Winner**

   The contract owner or Chainlink Automation will call `performUpKeep` its call `RandomWordsRequest`to VRF determine the winner.

   ```solidity
      function performUpKeep(bytes calldata /** performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep("");

        if (!upKeepNeeded) {
            revert Raffle__UpKeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint(s_raffleState)
            );
        }

        s_raffleState = RaffleState.CALCULATING;

        VRFV2PlusClient.RandomWordsRequest memory request = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            });

        uint256 requestId = s_vrfCoordinator.requestRandomWords(request);
        emit RequestRaffleWinner(requestId);
    }

   ```

3. **Distribute Prize**

   Once the random number is returned, the contract will automatically distribute the prize to the winner.

   ```solidity
      function fulfillRandomWords(
        uint256 /*requestId,*/,
        uint256[] calldata randomWords
    ) internal override {
        //Checks

        // Effect (Internal Contract State )
        uint256 indexOfWinner = randomWords[0] % s_players.length;
        address payable recentWinner = s_players[indexOfWinner];
        s_recentWinner = recentWinner;

        s_raffleState = RaffleState.OPEN;

        s_players = new address payable[](0);
        s_lastTimestamp = block.timestamp;
        emit WinnerPinked(s_recentWinner);

        // Interactions (External Contract Interactions)

        (bool success, ) = recentWinner.call{value: address(this).balance}("");
        if (!success) {
            revert Raffle_TransferFailed();
        }
    }
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License.

---

Happy coding! 🚀

## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
