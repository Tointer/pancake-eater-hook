// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract PoolMock {

    uint fee = 30;
    uint8 config;

    constructor() {}

    function setFee(uint _fee) external {
        fee = _fee;
    }

    function setPluginConfig(uint8 _config) external {
        config = _config;
    }

}
