// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy
import "../interfaces/IContractMetaData.sol";

abstract contract ContractMetaData is IContractMetaData {
  /// @dev The sender is not authorized to perform the action
  error ContractMetaDataUnauthorized();

  string public override contractURI;

  function setContractURI(string memory _uri) external override {
    if (!_canSetContractURI()) {
      revert ContractMetaDataUnauthorized();
    }

    _setUpContractURI(_uri);
  }

  function _setUpContractURI(string memory _uri) internal {
    string memory prevUri = contractURI;
    contractURI = _uri;
    emit ContractURIUpdated(prevUri, _uri);
  }

  function _canSetContractURI() internal view virtual returns (bool);
}
