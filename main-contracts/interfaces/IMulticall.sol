// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy


interface IMulticall {

    function muticall(bytes[] calldata data) external returns (bytes[] memory results);
}

