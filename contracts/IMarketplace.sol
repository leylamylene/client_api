// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

import "./IPlatformFee.sol";

interface IMarketplace is IPlatformFee {
  enum TokenType {
    ERC1155,
    ERC721
  }

  enum ListingType {
    Direct,
    Auction
  }

  struct Offer {
    uint256 listingId;
    address offeror;
    uint256 quantityWanted;
    address currency;
    uint256 pricePerToken;
    uint256 expirationTimestamp;
  }

  struct ListingParameters {
    address assetContract;
    uint256 tokenId;
    uint256 startTime;
    uint256 secondsUntilEndTime;
    uint256 quantityToList;
    address currencyToAccept;
    uint256 reservePricePerToken;
    uint256 buyoutPricePerToken;
    ListingType listingType;
  }

  struct Listing {
    uint256 listingId;
    address tokenOwner;
    address assetContract;
    uint256 tokenId;
    uint256 startTime;
    uint256 endTime;
    uint256 quantity;
    address currency;
    uint256 reservePricePerToken;
    uint256 buyoutPricePerToken;
    TokenType tokenType;
    ListingType listingType;
  }

  event ListingAdded(
    uint256 indexed listingId,
    address indexed assetContract,
    address indexed lister,
    Listing listing
  );

  /// @dev Emitted when the parameters of a listing are updated.
  event ListingUpdated(
    uint256 indexed listingId,
    address indexed listingCreator
  );

  /// @dev Emitted when a listing is cancelled.
  event ListingRemoved(
    uint256 indexed listingId,
    address indexed listingCreator
  );

  event NewSale(
    uint256 indexed listingId,
    address indexed assetContract,
    address indexed lister,
    address buyer,
    uint256 quantityBought,
    uint256 totalPricePaid
  );

  event NewOffer(
    uint256 indexed listingId,
    address indexed offeror,
    ListingType indexed listingType,
    uint256 quantityWanted,
    uint256 totalOfferAmount,
    address currency
  );

  /// @dev Emitted when an auction is closed.
  event AuctionClosed(
    uint256 indexed listingId,
    address indexed closer,
    bool indexed cancelled,
    address auctionCreator,
    address winningBidder
  );

  event AuctionBuffersUpdated(uint256 timeBuffer, uint256 bidBufferBps);

  function createListing(ListingParameters memory _params) external;

  function updateListing(
    uint256 _listingId,
    uint256 _quantityToList,
    uint256 _reservePricePerToken,
    uint256 _buyoutPricePerToken,
    address _currencyToAccept,
    uint256 _startTime,
    uint256 _secondsUntilEndTime
  ) external;

  function cancelDirectListing(uint256 _listingId) external;

  function buy(
    uint256 _listingId,
    address _buyFor,
    uint256 _quantity,
    address _currency,
    uint256 _totalPrice
  ) external payable;

  function offer(
    uint256 _listingId,
    uint256 _quantityWanted,
    address _currency,
    uint256 _pricePerToken,
    uint256 _expirationTimestamp
  ) external payable;

  function acceptOffer(
    uint256 _listingId,
    address _offeror,
    address _currency,
    uint256 _totalPrice
  ) external;

  function closeAuction(uint256 _listingId, address _closeFor) external;
}
