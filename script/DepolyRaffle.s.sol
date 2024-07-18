// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Raffle} from "src/Raffle.sol";

contract DepolyRaffle is Script {
    function run() public {}

    function depolyContract() public returns (Raffle, HelperConfig) {}
}
