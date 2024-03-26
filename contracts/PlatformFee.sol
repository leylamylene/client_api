// SPDX-License-Identifier: UNLICENCED
pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

import "./IPlatformFee.sol";

abstract contract PlatformFee is IPlatformFee {
  error PlatformFeeUnauthorized();
  address private platformFeeRecipient;
  uint16 private platformFeeBps;

  uint256 private constant MAX_BPS = 10_000;

  function getPlatformFeeRecipient() internal view returns (address) {
    return platformFeeRecipient;
  }

  function getPlatformFeeBps() internal view returns (uint16) {
    return platformFeeBps;
  }

  function getPlaformFeeInfo() external view returns (address, uint16) {
    return (platformFeeRecipient, platformFeeBps);
  }

  function setPlatformFeeInfo(
    address _platformFeeRecipient,
    uint256 _platformFeeBps
  ) external {
    if (!_canSetPlatformFeeInfo()) {
      revert PlatformFeeUnauthorized();
    }
    _setupPlatformFeeInfo(_platformFeeRecipient, _platformFeeBps);
  }

  function _setupPlatformFeeInfo(
    address _platformFeeRecipient,
    uint256 _platformFeeBps
  ) internal {
    require(_platformFeeBps <= MAX_BPS, "> MAX_BPS.");

    platformFeeBps = uint16(_platformFeeBps);
    platformFeeRecipient = _platformFeeRecipient;

    emit PlatformFeeUpdated(_platformFeeRecipient, _platformFeeBps);
  }

  function _canSetPlatformFeeInfo() internal view  virtual returns (bool) {}
}
