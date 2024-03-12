// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

interface IPlatformFee {
  function getPlaformFeeInfo() external view returns (address, uint16);

  function setPlatformFeeInfo(
    address _platfromFeeRecipient,
    uint256 _platformFeeBps
  ) external;

  event PlatfromFeeInfoUpdated(
    address indexed platfromFeeRecipient,
    uint256 platformFeeBps
  );
  event PlatformFeeUpdated(address platformFeeRecipient, uint256 flatFee);
}
