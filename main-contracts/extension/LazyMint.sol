// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../interfaces/ILazyMint.sol";
import "./BatchMintMetaData.sol";

abstract contract LazyMint is ILazyMint, BatchMintMetaData {
  error LazyMintUnauthorized();
  error LazyMintInvalidAmount();

  uint256 internal nextTokenIdToLazyMint;

  function lazyMint(
    uint256 _amount,
    string calldata _baseUriForTokens,
    bytes calldata _data
  ) public virtual override returns (uint256 batchId) {
    if (!_canLazyMint()) {
      revert LazyMintUnauthorized();
    }

    if (_amount == 0) {
      revert LazyMintInvalidAmount();
    }

    uint256 _startId = nextTokenIdToLazyMint;
    (nextTokenIdToLazyMint, batchId) = _batchMintMetaData(
      _startId,
      _amount,
      _baseUriForTokens
    );
    emit TokensLazyMinted(
      _startId,
      _startId + _amount,
      _baseUriForTokens,
      _data
    );

    return batchId;
  }

  function _canLazyMint() internal view virtual returns (bool);
}
