// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/IOwnable.sol";

abstract contract Ownable is IOwnable {
  error OwnableUnauthorized();

  address private _owner;
  modifier onlyOwner() {
    if (msg.sender != _owner) {
      revert OwnableUnauthorized();
    }
    _;
  }

  function owner() public view override returns (address) {
    return _owner;
  }

  function setOwner(address _newOwner) external override {
    if (!_canSetOwner()) {
      revert OwnableUnauthorized();
    }

    _setupOwner(_newOwner);
  }

  function _setupOwner(address _newOwner) internal {
    address _prevOwner = _owner;
    _owner = _newOwner;

    emit OwnerUpdated(_prevOwner, _newOwner);
  }

  function _canSetOwner() internal view virtual returns (bool);
}
