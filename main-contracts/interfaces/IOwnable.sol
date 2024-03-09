// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

///@author Laila EL Hajjamy ;

interface IOwnable {
  function owner() external view returns (address);

  function setOwner(address _newOwner) external;

  event OwnerUpdated(address indexed prevOwner, address indexed newOwner);
}
