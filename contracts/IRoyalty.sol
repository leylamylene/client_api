// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

import "./IERC2981.sol";

interface IRoyalty is IERC2981 {
  struct RoyaltyInfo {
    address recipient;
    uint256 bps;
  }

  function getDefaultRoyaltyInfo() external view returns (address, uint16);

  function setDefaultRoyaltyInfo(
    address _royaltyRecipient,
    uint256 _royaltyBps
  ) external;

  function setRoyaltyInfoForToken(
    uint256 tokenId,
    address recipient,
    uint256 bps
  ) external;

  function getRoyaltyInfoForToken(
    uint256 tokenId
  ) external view returns (address, uint16);

  event DefaultRoyalty(
    address indexed newRoyaltyRecipient,
    uint256 newRoyaltyBps
  );

  event RoyaltyForToken(
    uint256 indexed tokenId,
    address indexed royaltyRecipient,
    uint256 royaltyBps
  );
}
