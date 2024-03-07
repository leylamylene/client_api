// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

/// @author Laila El Hajjamy

library String {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
   */
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }

  /**
   * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
   */
  function toHexString(
    uint256 value,
    uint256 length
  ) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }

  function toHexStringChecksummed(
    address value
  ) internal pure returns (string memory str) {
    str = toHexString(value);
    assembly {
      let mask := shl(6, div(not(0), 255))
      let o := add(str, 0x22)
      let hashed := and(keccak256(o, 40), mul(34, mask))
      let t := shl(240, 136)
      for {
        let i := 0
      } 1 {

      } {
        mstore(add(i, i), mul(t, byte(i, hashed)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
      }
      mstore(o, xor(mload(o), shr(1, and(mload(0x00), and(mload(o), mask)))))
      o := add(o, 0x20)
      mstore(o, xor(mload(o), shr(1, and(mload(0x20), and(mload(o), mask)))))
    }
  }

  function toHexString(
    address value
  ) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(value);
    assembly {
      let strLength := add(mload(str), 2)
      mstore(str, 0x3078)
      str := sub(str, 2)
      mstore(str, strLength)
    }
  }

  function toHexStringNoPrefix(
    address value
  ) internal pure returns (string memory str) {
    assembly {
      str := mload(0x40)

      mstore(0x40, add(str, 0x80))

      mstore(0x0f, 0x30313233343536373839616263646566)

      str := add(str, 2)
      mstore(str, 40)

      let o := add(str, 0x20)
      mstore(add(o, 40), 0)

      value := shl(96, value)

      for {
        let i := 0
      } 1 {

      } {
        let p := add(o, add(i, i))
        let temp := byte(i, value)
        mstore8(add(p, 1), mload(and(temp, 15)))
        mstore8(p, mload(shr(4, temp)))
        i := add(i, 1)
        if eq(i, 20) {
          break
        }
      }
    }
  }

  function toHexString(
    bytes memory raw
  ) internal pure returns (string memory str) {
    str = toHexStringNoPrefix(raw);
    assembly {
      let strLength := add(mload(str), 2)
      mstore(str, 0x3078)
      str := sub(str, 2)
      mstore(str, strLength)
    }
  }

  function toHexStringNoPrefix(
    bytes memory raw
  ) internal pure returns (string memory str) {
    assembly {
      let length := mload(raw)
      str := add(mload(0x40), 2)
      mstore(str, add(length, length))

      mstore(0x0f, 0x30313233343536373839616263646566)

      let o := add(str, 0x20)
      let end := add(raw, length)

      for {

      } iszero(eq(raw, end)) {

      } {
        raw := add(raw, 1)
        mstore8(add(o, 1), mload(and(mload(raw), 15)))
        mstore8(o, mload(and(shr(4, mload(raw)), 15)))
        o := add(o, 2)
      }
      mstore(o, 0)
      mstore(0x40, add(o, 0x20))
    }
  }
}
