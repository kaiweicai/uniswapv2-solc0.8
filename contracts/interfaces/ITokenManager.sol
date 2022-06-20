//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITokenManager {
    function isTokenAUsdt(address[] memory path)external view returns(bool[] memory trade);
}

