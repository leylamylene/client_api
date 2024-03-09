// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy

interface IContractMetaData {
  function contractURI() external view returns (string memory);

  /// @dev Only module admin can call this function

  function setContractURI(string calldata _uri) external;

  event ContractURIUpdated(string prevURI, string newURI);
}
