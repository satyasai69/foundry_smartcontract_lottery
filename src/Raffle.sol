// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
 * @title A simple raffle contract
 * @author me
 * @notice This contract to creact a  simple raffle
 * @dev ChainlinkVRFv2.5
 */
contract Raffle is VRFConsumerBaseV2Plus {
    /* Errors */
    error SendMoreToEnterRaffle();
    error Raffle_TransferFailed();
    error Raffle__RaffleNotOpen();
    error Raffle_UpKeepNotNaeed(
        uint256 balance,
        uint256 playerLength,
        uint256 raffleState
    );

    /** Type Declarations */

    enum RaffleState {
        OPEN, //0
        CALCULATING //1
    }

    /** state Variables */

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_enterancefee;
    uint256 private immutable i_interval;
    bytes32 private immutable i_keyHash;
    uint256 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    address payable[] private s_players;
    uint256 private s_lastTimestamp;
    address private s_recentWinner;

    RaffleState private s_raffleState;

    /** Events */

    event RaffleEntered(address indexed player);
    event WinnerPinked(address indexed Winner);

    constructor(
        uint256 enterancefee,
        uint256 interval,
        address _vrfCoordinator,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2Plus(_vrfCoordinator) {
        i_enterancefee = enterancefee;
        i_interval = interval;
        i_keyHash = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;

        s_lastTimestamp = block.timestamp;
        s_raffleState = RaffleState.OPEN;
    }

    function enterRaffle() external payable {
        //  require(msg.value >= i_enterancefee, "Not enough ETH send!");
        //  require(msg.value >= i_enterancefee, SendMoreToEnterRaffle());
        if (msg.value < i_enterancefee) {
            revert SendMoreToEnterRaffle();
        }

        if (s_raffleState != RaffleState.OPEN) {
            revert Raffle__RaffleNotOpen();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    // When should the winner be picked
    /**
     * @dev This is the function chainlink node will call
     * @param  - ignored
     * @return upKeepNeeded - true if its time to restart the lottery
     * @return  - ignored
     */

    function checkUpKeep(
        bytes memory /** checkData */
    ) public view returns (bool upKeepNeeded, bytes memory /** performData */) {
        bool timeHasPassed = ((block.timestamp - s_lastTimestamp) >=
            i_interval);
        bool isOpen = s_raffleState == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_players.length > 0;

        bool upKeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;

        return (upKeepNeeded, "");
    }

    // 1. Get a  Random number
    // 2. Use Random number to pick a player
    // 3. be automatically called

    function performUpKeep(bytes calldata /** performData */) external {
        (bool upKeepNeeded, ) = checkUpKeep("");

        if (!upKeepNeeded) {
            revert Raffle_UpKeepNotNaeed(
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
    }

    /** Getter function to read enterancefee */

    function getEnterancefee() public view returns (uint256) {
        return i_enterancefee;
    }

    // CEI : Checks, Effect, Interactions
    function fulfillRandomWords(
        uint256 requestId,
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
}
