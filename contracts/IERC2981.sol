// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IERC165.sol";

interface IERC2981 is IERC165 {
  /// @dev Returns how much royalty is owed and to whom
  function royaltyInfo(
    uint256 tokenId,
    uint256 salePrice
  ) external view returns (address receiver, uint256 royaltyAmount);
}
