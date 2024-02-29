// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

contract BSCMainnetAddressBook {
    struct Addresses{
        address pancakeSwapV3QuoterV2;
        address pancakeSwapV3RouterV3;
        address pancakeSwapV3PositionManager;
        address pancakeSwapV3Factory;
    }

    Addresses public addresses;

    constructor() {
        addresses = Addresses({
            pancakeSwapV3QuoterV2: 0xB048Bbc1Ee6b733FFfCFb9e9CeF7375518e25997,
            pancakeSwapV3RouterV3: 0x1b81D678ffb9C0263b24A97847620C99d213eB14,
            pancakeSwapV3PositionManager: 0x46A15B0b27311cedF172AB29E4f4766fbE7F4364,
            pancakeSwapV3Factory: 0x0BFbCF9fa4f9C56B0F40a671Ad40E0805A091865
        });
    }
}
