// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
/// @author Laila El Hajjamy, thirdweb

import "./Address.sol";

import "./IMulticall.sol";

contract Multicall is IMulticall {
  function muticall(
    bytes[] calldata data
  ) external returns (bytes[] memory results) {
    results = new bytes[](data.length);
    address sender = _msgSender();
    bool isForwarder = msg.sender != sender;

    for (uint256 i = 0; i < data.length; i++) {
      if (isForwarder) {
        results[i] = Address.functionDelegateCall(
          address(this),
          abi.encodePacked(data[i], sender)
        );
      } else {
        results[i] = Address.functionDelegateCall(address(this), data[i]);
      }
    }
  }

  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
}
