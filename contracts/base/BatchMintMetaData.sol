// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy


contract BatchMintMetadata {
    error BatchMintInvalidBatchId(uint256 index);

    error BatchMintInvalidTokenId(uint256 tokenId);

    error BatchMintMetadataFrozen(uint256 batchId);

    uint256[] private batchIds;

    mapping(uint256 => string) private baseURIs;

    mapping(uint256 => bool) public batchFrozen;

    event MetadataFrozen();

 
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

    function _getBatchId(uint256 _tokenId) internal view returns (uint256 batchId, uint256 index) {
        uint256 numOfTokenBatches = getBaseURICount();
        uint256[] memory indices = batchIds;

        for (uint256 i = 0; i < numOfTokenBatches; i += 1) {
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

        for (uint256 i = 0; i < numOfTokenBatches; i += 1) {
            if (_tokenId < indices[i]) {
                return baseURIs[indices[i]]; 
            }
        }

        revert BatchMintInvalidTokenId(_tokenId);
    }

    function _getBatchStartId(uint256 _batchID) internal view returns (uint256) {
        uint256 numOfTokenBatches = getBaseURICount();
        uint256[] memory indices = batchIds;

        for (uint256 i = 0; i < numOfTokenBatches; i++) {
            if (_batchID == indices[i]) {
                if (i > 0) {
                    return indices[i - 1];
                }
                return 0;
            }
        }

        revert BatchMintInvalidBatchId(_batchID);
    }

    function _setBaseURI(uint256 _batchId, string memory _baseURI) internal {
        if (batchFrozen[_batchId]) {
            revert BatchMintMetadataFrozen(_batchId);
        }
        baseURIs[_batchId] = _baseURI;
        emit BatchMetadataUpdate(_getBatchStartId(_batchId), _batchId);
    }

    function _freezeBaseURI(uint256 _batchId) internal {
        string memory baseURIForBatch = baseURIs[_batchId];
        if (bytes(baseURIForBatch).length == 0) {
            revert BatchMintInvalidBatchId(_batchId);
        }
        batchFrozen[_batchId] = true;
        emit MetadataFrozen();
    }

    function _batchMintMetadata(
        uint256 _startId,
        uint256 _amountToMint,
        string memory _baseURIForTokens
    ) internal returns (uint256 nextTokenIdToMint, uint256 batchId) {
        batchId = _startId + _amountToMint;
        nextTokenIdToMint = batchId;

        batchIds.push(batchId);

        baseURIs[batchId] = _baseURIForTokens;
    }
}
