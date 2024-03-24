// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

import "./IRoyalty.sol";

abstract contract Royalty is IRoyalty {
  error RoyaltyUnauthorized();

  error RoyaltyInvalidRecipient();

  error RoyaltyExeededMaxFeeBps(uint256 max, uint256 actual);

  address private royaltyRecipient;

  uint16 private royaltyBps;

  mapping(uint256 => RoyaltyInfo) private royaltyInfoForToken;

  function royaltyInfo(
    uint256 tokenId,
    uint256 salePrice
  )
    external
    view
    virtual
    override
    returns (address receiver, uint256 royaltyAmount)
  {
    (address recipient, uint256 bps) = getRoyaltyInfoForToken(tokenId);
    receiver = recipient;
    royaltyAmount = (salePrice * bps) / 10_000;
  }

  function getRoyaltyInfoForToken(
    uint256 _tokenId
  ) public view override returns (address, uint16) {
    RoyaltyInfo memory royaltyForToken = royaltyInfoForToken[_tokenId];

    return
      royaltyForToken.recipient == address(0)
        ? (royaltyRecipient, uint16(royaltyBps))
        : (royaltyForToken.recipient, uint16(royaltyForToken.bps));
  }

  function getDefaultRoyaltyInfo()
    external
    view
    override
    returns (address, uint16)
  {
    return (royaltyRecipient, uint16(royaltyBps));
  }

  function setDefaultRoyaltyInfo(
    address _royaltyRecipient,
    uint256 _royaltyBps
  ) external override {
    if (!_canSetRoyaltyInfo()) {
      revert RoyaltyUnauthorized();
    }

    _setupDefaultRoyaltyInfo(_royaltyRecipient, _royaltyBps);
  }

  function _setupDefaultRoyaltyInfo(
    address _royaltyRecipient,
    uint256 _royaltyBps
  ) internal {
    if (_royaltyBps > 10_000) {
      revert RoyaltyExeededMaxFeeBps(10_000, _royaltyBps);
    }

    royaltyRecipient = _royaltyRecipient;
    royaltyBps = uint16(_royaltyBps);
    emit DefaultRoyalty(_royaltyRecipient, _royaltyBps);
  }

  function setRoyaltyInfoForToken(
    uint256 _tokenId,
    address _recipient,
    uint256 _bps
  ) external override {
    if (!_canSetRoyaltyInfo()) {
      revert RoyaltyUnauthorized();
    }

    _setupRoyaltyInfoForToken(_tokenId, _recipient, _bps);
  }

  function _setupRoyaltyInfoForToken(
    uint256 _tokenId,
    address _recipient,
    uint256 _bps
  ) internal {
    if (_bps > 10_000) {
      revert RoyaltyExeededMaxFeeBps(10_000, _bps);
    }

    royaltyInfoForToken[_tokenId] = RoyaltyInfo({
      recipient: _recipient,
      bps: _bps
    });
    emit RoyaltyForToken(_tokenId, _recipient, _bps);
  }

  function _canSetRoyaltyInfo() internal view virtual returns (bool);
}
