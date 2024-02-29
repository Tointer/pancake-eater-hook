// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

contract ARBMainnetAddressBook {
    struct Addresses{
        address uniswapV3Factory;
        address uniswapV3NFTManager;
        address usdc;
        address usdcBridged;
        address usdt;
    }

    Addresses public addresses;

    constructor() {
        addresses = Addresses({
            uniswapV3Factory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            uniswapV3NFTManager: 0xC36442b4a4522E871399CD717aBDD847Ab11FE88,
            usdc: 0xaf88d065e77c8cC2239327C5EDb3A432268e5831,
            usdcBridged: 0xFF970A61A04b1cA14834A43f5dE4533eBDDB5CC8,
            usdt: 0xFd086bC7CD5C481DCC9C85ebE478A1C0b69FCbb9
        });
    }
}
