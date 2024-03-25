// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./ERC721Drop.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ERC721DropFactory {
  address public implementationAddress;
  address public platfromFeeRecipient;
  uint256 public platformFeeBps;
  address public operator;
  address public owner;
  event ERC721DropCreated(address newERC721Drop);

  constructor(
    address _implementationAddress,
    address _platfromFeeRecipient,
    uint256 _platformFeeBps,
    address _operator
  ) {
    owner = msg.sender;
    implementationAddress = _implementationAddress;
    platfromFeeRecipient = _platfromFeeRecipient;
    platformFeeBps = _platformFeeBps;
    operator = _operator;
  }

  modifier onlyOwner() {
    require(
      msg.sender == owner,
      "Not authorized: Only owner can call this function"
    );
    _; // Execute the rest of the function code
  }

  function setOwner(address _owner) public onlyOwner {
    owner = _owner;
  }

  function setImplementationAddress(
    address _implementationAddress
  ) public onlyOwner {
    implementationAddress = _implementationAddress;
  }

  function setPlatfromFeeRecipient(
    address _platformRecipient
  ) public onlyOwner {
    platfromFeeRecipient = _platformRecipient;
  }

  function setPlatformFeeBps(uint256 _platformFeeBps) public onlyOwner {
    platformFeeBps = _platformFeeBps;
  }

  function setOperator(address _operator) public onlyOwner {
    operator = _operator;
  }

  function createClone(
    string memory _name,
    string memory _symbol
  ) public returns (address proxy) {
    proxy = Clones.clone(implementationAddress);
    ERC721Drop(proxy).init(
      _name,
      _symbol,
      msg.sender,
      msg.sender,
      1000,
      msg.sender,
      platfromFeeRecipient,
      platformFeeBps,
      operator
    );

    emit ERC721DropCreated(proxy);
  }
}
