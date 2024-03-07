// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy

abstract contract Royalty {
  error RoyaltyUnauthorized();

  error RoyaltyInvalidRecipient(address recipient);

  error RoyaltyExceededMaxFeeBps(uint256 max, uint256 actual);

  event DefaultRoyalty(address recipient, uint256 bps);

  event RoyaltyForTokenUpdated(uint256 token, address recipient, uint256 bps);
  address private royaltyRecipient;

  uint16 private royaltyBps;

  mapping(uint256 => RoyaltyInfo) private royaltyInfoForToken;

  struct RoyaltyInfo {
    address recipient;
    uint256 bps;
  }

  function getRoyaltyInfo(
    uint256 tokenId,
    uint256 salePrice
  ) external view virtual returns (address receiver, uint256 royaltyAmount) {
    (address recipient, uint256 bps) = getRoyaltyForToken(tokenId);
    receiver = recipient;
    royaltyAmount = (salePrice * bps) / 10_000;
  }

  function getRoyaltyForToken(
    uint256 _tokenId
  ) internal view returns (address, uint16) {
    RoyaltyInfo memory royaltyToken = royaltyInfoForToken[_tokenId];

    return
      royaltyToken.recipient == address(0)
        ? (royaltyRecipient, uint16(royaltyToken.bps))
        : (royaltyToken.recipient, uint16(royaltyToken.bps));
  }

  function getDefaultRoyaltyInfo() external view returns (address, uint16) {
    return (royaltyRecipient, uint16(royaltyBps));
  }

  function _setDefaultRoyaltyInfo(
    address _royaltyRecipient,
    uint256 _royaltyBps
  ) internal {
    if (!_canSetRoyaltyInfo()) {
      revert RoyaltyUnauthorized();
    }
    if (_royaltyBps > 10_000) {
      revert RoyaltyExceededMaxFeeBps(10_000, _royaltyBps);
    }

    royaltyRecipient = _royaltyRecipient;
    royaltyBps = uint16(_royaltyBps);

    emit DefaultRoyalty(_royaltyRecipient, _royaltyBps);
  }

  function setRoyaltyInfoForToken(
    uint256 _tokenId,
    address _recipient,
    uint256 _bps
  ) external {
    if (!_canSetRoyaltyInfo()) {
      revert RoyaltyUnauthorized();
    }

    if (_bps > 10_000) {
      revert RoyaltyExceededMaxFeeBps(10_000, _bps);
    }
    royaltyInfoForToken[_tokenId] = RoyaltyInfo({
      recipient: _recipient,
      bps: _bps
    });

    emit RoyaltyForTokenUpdated(_tokenId, _recipient, _bps);
  }

  function _canSetRoyaltyInfo() internal view virtual returns (bool);
}
