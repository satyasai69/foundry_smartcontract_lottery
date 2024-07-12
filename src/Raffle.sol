// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

/**
 * @title A simple raffle contract
 * @author me
 * @notice This contract to creact a  simple raffle
 * @dev ChainlinkVRFv2.5
 */
contract Raffle {
    uint256 private immutable i_enterancefee;

    constructor(uint256 enterancefee) {
        i_enterancefee = enterancefee;
    }

    function enterRaffle() public {}

    function pickWinner() public {}

    /** Getter function to read enterancefee */

    function getEnterancefee() public view returns (uint256) {
        return i_enterancefee;
    }
}
