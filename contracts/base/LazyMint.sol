// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy

import "./BatchMintMetadata.sol";

abstract contract LazyMint is BatchMintMetadata {
  event TokensLazyMinted(
    uint256 indexed startTokenId,
    uint256 endTokenId,
    string baseURI,
    bytes encryptedBaseURI
  );

  error LazyMintUnauthorized();
  error LazyMintInvalidAmount();

  uint256 internal nextTokenIdToLazyMint;

  function lazyMint(
    uint256 _amount,
    string calldata _baseURIForTokens,
    bytes calldata _data
  ) public virtual returns (uint256 batchId) {
    if (!_canLazyMint()) {
      revert LazyMintUnauthorized();
    }

    if (_amount == 0) {
      revert LazyMintInvalidAmount();
    }

    uint256 startId = nextTokenIdToLazyMint;

    (nextTokenIdToLazyMint, batchId) = _batchMintMetadata(
      startId,
      _amount,
      _baseURIForTokens
    );

    emit TokensLazyMinted(
      startId,
      startId + _amount - 1,
      _baseURIForTokens,
      _data
    );

    return batchId;
  }

  function _canLazyMint() internal view virtual returns (bool);
}
