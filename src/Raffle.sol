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

/**
 * @title A simple raffle contract
 * @author me
 * @notice This contract to creact a  simple raffle
 * @dev ChainlinkVRFv2.5
 */
contract Raffle {
    /* Errors */
    error SendMoreToEnterRaffle();

    uint256 private immutable i_enterancefee;

    address payable[] private s_players;

    /** Events */

    event RaffleEntered(address indexed player);

    constructor(uint256 enterancefee) {
        i_enterancefee = enterancefee;
    }

    function enterRaffle() public payable {
        //  require(msg.value >= i_enterancefee, "Not enough ETH send!");
        //  require(msg.value >= i_enterancefee, SendMoreToEnterRaffle());
        if (msg.value < i_enterancefee) {
            revert SendMoreToEnterRaffle();
        }

        s_players.push(payable(msg.sender));
        emit RaffleEntered(msg.sender);
    }

    function pickWinner() public {}

    /** Getter function to read enterancefee */

    function getEnterancefee() public view returns (uint256) {
        return i_enterancefee;
    }
}
