// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

interface IDelayedReveal {
  /// @dev emitted when tokens are revealed
  event TokenURIRevealed(uint256 indexed index, string revealedURI);

  /**
   *
   * @param identifer The Id for the batch of delayed-reveal NFTs to reveal
   * @param key The key with which the base URI for the relevant batch of NFTs was encrypted
   */
  function reveal(
    uint256 identifer,
    bytes calldata key
  ) external returns (string memory revealedURI);

  /**
   *
   * @param data the datat to encrypt , the revealed state base uri of the relevent bach of NFTs
   * @param key the key with which to encypt the data
   */
  function encryptDecrypt(
    bytes memory data,
    bytes calldata key
  ) external pure returns (bytes memory result);
}
