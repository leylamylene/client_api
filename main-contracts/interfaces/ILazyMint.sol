// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author Laila El Hajjamy

interface ILazyMint {
  /// @dev Emitted when tokens are lazy minted.
  event TokensLazyMinted(
    uint256 indexed startTokenId,
    uint256 endTokenId,
    string baseURI,
    bytes encryptedBaseURI
  );

  function lazyMint(
    uint256 amount,
    string calldata baseURIForTokens,
    bytes calldata extraData
  ) external returns (uint256 batchId);
}
