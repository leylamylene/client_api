// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy

abstract contract DelayedReveal {
  error DelayedRevealNothingToReveal();

  error DelayedRevealIncorrectResultHash(bytes32 expected, bytes32 actual);

  mapping(uint256 => bytes) public encryptedData;

  function _setEncryptedData(
    uint256 _batchId,
    bytes memory _encryptedData
  ) internal {
    encryptedData[_batchId] = _encryptedData;
  }

  function getRevealURI(
    uint256 _batchId,
    bytes calldata _key
  ) public view returns (string memory revealedURI) {
    bytes memory data = encryptedData[_batchId];
    if (data.length == 0) {
      revert DelayedRevealNothingToReveal();
    }

    (bytes memory encryptedURI, bytes32 provenanceHash) = abi.decode(
      data,
      (bytes, bytes32)
    );

    revealedURI = string(encryptDecrypt(encryptedURI, _key));

    if (
      keccak256(abi.encodePacked(revealedURI, _key, block.chainid)) !=
      provenanceHash
    ) {
      revert DelayedRevealIncorrectResultHash(
        provenanceHash,
        keccak256(abi.encodePacked(revealedURI, _key, block.chainid))
      );
    }
  }

  function encryptDecrypt(
    bytes memory data,
    bytes calldata key
  ) public pure returns (bytes memory result) {
    uint256 length = data.length;

    assembly {
      result := mload(0x40)
      mstore(0x40, add(add(result, length), 32))
      mstore(result, length)
    }

    for (uint256 i = 0; i < length; i += 32) {
      bytes32 hash = keccak256(abi.encodePacked(key, i));

      bytes32 chunk;
      assembly {
        chunk := mload(add(data, add(i, 32)))
      }
      chunk ^= hash;
      assembly {
        mstore(add(result, add(i, 32)), chunk)
      }
    }
  }

  function isEncryptedBatch(uint256 _batchId) public view returns (bool) {
    return encryptedData[_batchId].length > 0;
    // .length coz  encryptedData[_batchId] is of type bytes
  }
}
