// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb


interface IMulticall {

    function muticall(bytes[] calldata data) external returns (bytes[] memory results);
}

