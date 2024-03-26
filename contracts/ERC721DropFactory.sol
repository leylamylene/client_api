// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./ERC721Drop.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract ERC721DropFactory {
  address public implementationAddress;
  address public owner;
  address[] public allClones;
  mapping(address => address) public list;
  event ERC721DropCreated(address newERC721Drop);

  constructor(address _implementationAddress) {
    owner = msg.sender;
    implementationAddress = _implementationAddress;
  }

  modifier onlyOwner() {
    require(
      msg.sender == owner,
      "Not authorized: Only owner can call this function"
    );
    _; // Execute the rest of the function code
  }

  function setOwner(address _owner) public payable onlyOwner {
    owner = _owner;
  }

  function setImplementationAddress(
    address _implementationAddress
  ) public payable onlyOwner {
    implementationAddress = _implementationAddress;
  }


  function createClone(
    string memory _name,
    string memory _symbol,
    address operator
  ) public payable returns (address instance) {
    instance = Clones.clone(implementationAddress);

    (bool success, ) = instance.call{value: msg.value}(
      abi.encodeWithSignature(
        "init(string,string,address,address,uint128,address,address)",
        _name,
        _symbol,
        msg.sender,
        msg.sender,
        1000,
        msg.sender,
        operator
      )
    );
    allClones.push(instance);
    list[msg.sender] = instance;
    emit ERC721DropCreated(instance);
    return instance;
  }
}
