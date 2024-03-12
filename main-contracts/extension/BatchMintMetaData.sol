// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy , thirdweb

contract BatchMintMetaData {
  error BatchMintInvalidBatchId(uint256 index);

  error BatchMintInvalidTokenId(uint256 tokeId);

  error BatchMintMetadataFrozen(uint256 batchId);

  /// @dev Largest tokenId of each batch of tokens with the same baseURI + 1 {ex : batchId 100 at position 0 includes tokens 0-99}
  uint256[] private batchIds;

  mapping(uint256 => string) private baseURI;

  mapping(uint256 => bool) public batchFrozen;

  event MetadataFrozen();

  // third parties can listen to this event and update images und related attributes if the metadata of a range of tokens change
  event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);

  function getBaseURICount() public view returns (uint256) {
    return batchIds.length;
  }

  function getBatchIdAtIndex(uint256 _index) public view returns (uint256) {
    if (_index >= getBaseURICount()) {
      revert BatchMintInvalidBatchId(_index);
    }

    return batchIds[_index];
  }

  /// @dev get the Id of the batch of tokens the given tokenId belongs to

  function _getBatchId(
    uint256 _tokenId
  ) internal view returns (uint256 batchId, uint256 index) {
    uint256 numOfTokenBatches = getBaseURICount();
    uint256[] memory indices = batchIds;

    for (uint256 i = 0; i < numOfTokenBatches; i++) {
      if (_tokenId < indices[i]) {
        index = i;

        batchId = indices[i];
        return (batchId, index);
      }
    }

    revert BatchMintInvalidTokenId(_tokenId);
  }

  function _getBaseURI(uint256 _tokenId) internal view returns (string memory) {
    uint256 numOfTokenBatches = getBaseURICount();
    uint256[] memory indices = batchIds;

    for (uint256 i = 0; i < numOfTokenBatches; i++) {
      if (_tokenId < indices[i]) {
        return baseURI[indices[i]];
      }
    }

    revert BatchMintInvalidTokenId(_tokenId);
  }

  /// @dev get the starting tokenId of a given batchId
  function _getBatchStartId(uint256 _batchId) internal view returns (uint256) {
    uint256 numOfTokenBatches = getBaseURICount();
    uint256[] memory indices = batchIds;

    for (uint256 i = 0; i < numOfTokenBatches; i++) {
      if (_batchId == indices[i]) {
        if (i > 0) {
          return indices[i - 1];
        }
        return 0;
      }
    }
    revert BatchMintInvalidBatchId(_batchId);
  }

  function _setBaseURI(uint256 _batchId, string memory _baseURI) internal {
    if (batchFrozen[_batchId]) {
      revert BatchMintMetadataFrozen(_batchId);
    }

    baseURI[_batchId] = _baseURI;
    // toToken = _batchId - 1 ; to test later
    emit BatchMetadataUpdate(_getBatchStartId(_batchId), _batchId);
  }

  function _freezeBaseURI(uint256 _batchId) internal {
    string memory baseURIForBatch = baseURI[_batchId];
    if (bytes(baseURIForBatch).length == 0) {
      revert BatchMintInvalidBatchId(_batchId);
    }
    batchFrozen[_batchId] = true;
    emit MetadataFrozen();
  }

  function _batchMintMetaData(
    uint256 _startId,
    uint256 _amountToMint,
    string memory _baseURIForTokens
  ) internal returns (uint256 nextTokenIdToMint, uint256 batchId) {
    batchId = _startId + _amountToMint;
    nextTokenIdToMint = batchId;
    batchIds.push(batchId);
    baseURI[batchId] = _baseURIForTokens;
  }
}
