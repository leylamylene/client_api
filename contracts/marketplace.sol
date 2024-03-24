// SPDX-Licence-Identifier : MIT
pragma solidity ^0.8.19;

/// @author Laila El hajjamy, thirdweb
// change this later with ERC1155A if needed and all its occurences
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./IMarketplace.sol";
import "./Permissions.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "./IERC721A.sol";
import "./ReentrancyGuard.sol";
import "./CurrencyTransferLib.sol";

contract Marketplace is
  IPlatformFee,
  IMarketplace,
  Permissions,
  IERC165,
  IERC721Receiver,
  IERC1155Receiver,
  ReentrancyGuard
{
  using SafeCast for uint256;

  uint256 public totalListings;

  string public contractURI;

  address private platformFeeRecipient;
  bytes32 private constant LISTER_ROLE = keccak256("LISTER_ROLE");
  bytes32 private constant ASSET_ROLE = keccak256("ASSET_ROLE");

  uint64 public constant MAX_BPS = 10_000;
  /// @dev The address of the native token wrapper contract.
  address private immutable nativeTokenWrapper;
  uint64 private platformFeeBps;

  uint64 public timeBuffer;

  uint64 public bidBufferBps;
  mapping(uint256 => Listing) public listings;

  mapping(uint256 => mapping(address => Offer)) public offers;

  mapping(uint256 => Offer) public winningBid;

  modifier onlyListingCreator(uint256 _listingId) {
    require(
      listings[_listingId].tokenOwner == _msgSender(),
      "Only the listing creator can perform this action"
    );
    _;
  }

  modifier onlyExistingListing(uint256 _listingId) {
    require(
      listings[_listingId].assetContract != address(0),
      "Listing doesn't exiist"
    );
    _;
  }

  constructor(address _nativeTokenWrapper) {
    nativeTokenWrapper = _nativeTokenWrapper;
  }

  function initialize(
    address _defaultAdmin,
    string memory _contractURI,
    address _platformFeeRecipient,
    uint256 _platformFeeBps
  ) external {
    timeBuffer = 15 minutes;
    bidBufferBps = 500;

    contractURI = _contractURI;
    platformFeeBps = uint64(_platformFeeBps);
    platformFeeRecipient = _platformFeeRecipient;

    _setupRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
    _setupRole(LISTER_ROLE, address(0));
    _setupRole(ASSET_ROLE, address(0));
  }

  receive() external payable {}

  function onERC1155Received(
    address,
    address,
    uint256,
    uint256,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155Received.selector;
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {
    return this.onERC721Received.selector;
  }

  function onERC1155BatchReceived(
    address,
    address,
    uint256[] memory,
    uint256[] memory,
    bytes memory
  ) public virtual override returns (bytes4) {
    return this.onERC1155BatchReceived.selector;
  }

  function createListing(ListingParameters memory _params) external override {
    uint256 listingId = totalListings;
    totalListings += 1;

    address tokenOwner = _msgSender();
    TokenType tokenTypeOfListing = getTokenType(_params.assetContract);
    uint256 tokenAmountToList = getSafeQuantity(
      tokenTypeOfListing,
      _params.quantityToList
    );

    require(tokenAmountToList > 0, " Quantity is invalid");
    require(
      hasRole(LISTER_ROLE, address(0)) || hasRole(LISTER_ROLE, _msgSender()),
      " The caller should have a sender"
    );

    require(
      hasRole(ASSET_ROLE, address(0)) ||
        hasRole(ASSET_ROLE, _params.assetContract),
      " Caller should be an asset"
    );
    uint256 startTime = _params.startTime;
    if (startTime < block.timestamp) {
      // do not let the listing to start in the past 1 hour buufer
      require(
        block.timestamp - startTime < 1 hours,
        "Can't start in the past one hour"
      );
      startTime = block.timestamp;
    }

    validateOwnershipAndApproval(
      tokenOwner,
      _params.assetContract,
      _params.tokenId,
      tokenAmountToList,
      tokenTypeOfListing
    );
    Listing memory newListing = Listing({
      listingId: listingId,
      tokenOwner: tokenOwner,
      assetContract: _params.assetContract,
      tokenId: _params.tokenId,
      startTime: startTime,
      endTime: startTime + _params.secondsUntilEndTime,
      quantity: tokenAmountToList,
      currency: _params.currencyToAccept,
      reservePricePerToken: _params.reservePricePerToken,
      buyoutPricePerToken: _params.buyoutPricePerToken,
      tokenType: tokenTypeOfListing,
      listingType: _params.listingType
    });

    listings[listingId] = newListing;
    if (newListing.listingType == ListingType.Auction) {
      require(
        newListing.buyoutPricePerToken == 0 ||
          newListing.buyoutPricePerToken >= newListing.reservePricePerToken,
        "RESERVE"
      );

      transferListingTokens(
        tokenOwner,
        address(this),
        tokenAmountToList,
        newListing
      );

      emit ListingAdded(
        listingId,
        _params.assetContract,
        tokenOwner,
        newListing
      );
    }
  }

  /// @dev Lets a listing's creator edit the listing's parameters.
  function updateListing(
    uint256 _listingId,
    uint256 _quantityToList,
    uint256 _reservePricePerToken,
    uint256 _buyoutPricePerToken,
    address _currencyToAccept,
    uint256 _startTime,
    uint256 _secondsUntilEndTime
  ) external override onlyListingCreator(_listingId) {
    Listing memory targetListing = listings[_listingId];
    uint256 safeNewQuantity = getSafeQuantity(
      targetListing.tokenType,
      _quantityToList
    );
    bool isAuction = targetListing.listingType == ListingType.Auction;

    require(safeNewQuantity != 0, "QUANTITY");

    // Can only edit auction listing before it starts.

    if (isAuction) {
      require(block.timestamp < targetListing.startTime, "STARTED");
      require(
        _buyoutPricePerToken == 0 ||
          _buyoutPricePerToken >= _reservePricePerToken,
        "RESERVE"
      );
    }

    if (_startTime < block.timestamp) {
      // do not allow listing to start in the past (1 hour buffer)
      require(block.timestamp - _startTime < 1 hours, "ST");
      _startTime = block.timestamp;
    }

    uint256 newStartTime = _startTime == 0
      ? targetListing.startTime
      : _startTime;
    listings[_listingId] = Listing({
      listingId: _listingId,
      tokenOwner: _msgSender(),
      assetContract: targetListing.assetContract,
      tokenId: targetListing.tokenId,
      startTime: newStartTime,
      endTime: _secondsUntilEndTime == 0
        ? targetListing.endTime
        : newStartTime + _secondsUntilEndTime,
      quantity: safeNewQuantity,
      currency: _currencyToAccept,
      reservePricePerToken: _reservePricePerToken,
      buyoutPricePerToken: _buyoutPricePerToken,
      tokenType: targetListing.tokenType,
      listingType: targetListing.listingType
    });

    if (targetListing.quantity != safeNewQuantity) {
      if (isAuction) {
        transferListingTokens(
          address(this),
          targetListing.tokenOwner,
          targetListing.quantity,
          targetListing
        );
      }

      validateOwnershipAndApproval(
        targetListing.tokenOwner,
        targetListing.assetContract,
        targetListing.tokenId,
        safeNewQuantity,
        targetListing.tokenType
      );

      // Escrow the new quantity of tokens to list in the auction.
      if (isAuction) {
        transferListingTokens(
          targetListing.tokenOwner,
          address(this),
          safeNewQuantity,
          targetListing
        );
      }
    }

    emit ListingUpdated(_listingId, targetListing.tokenOwner);
  }

  function cancelDirectListing(
    uint256 _listingId
  ) external onlyListingCreator(_listingId) {
    Listing memory targetListing = listings[_listingId];

    require(targetListing.listingType == ListingType.Direct, "!DIRECT");

    delete listings[_listingId];

    emit ListingRemoved(_listingId, targetListing.tokenOwner);
  }

  /*////////////////////////////////////////////////////////////////////
                     Direct listings sales logic
/////////////////////////////////////////////////////////////////////*/

  function buy(
    uint256 _listingId,
    address _buyFor,
    uint256 _quantityToBuy,
    address _currency,
    uint256 _totalPrice
  ) external payable override nonReentrant onlyExistingListing(_listingId) {
    Listing memory targetListing = listings[_listingId];
    address payer = _msgSender();
    require(
      _currency == targetListing.currency &&
        _totalPrice == (targetListing.buyoutPricePerToken * _quantityToBuy),
      "! Price or currency is invalid"
    );

    executeSale(
      targetListing,
      payer,
      _buyFor,
      targetListing.currency,
      targetListing.buyoutPricePerToken * _quantityToBuy,
      _quantityToBuy
    );
  }

  function acceptOffer(
    uint256 _listingId,
    address _offeror,
    address _currency,
    uint256 _pricePerToken
  )
    external
    override
    nonReentrant
    onlyExistingListing(_listingId)
    onlyListingCreator(_listingId)
  {
    Offer memory targetOffer = offers[_listingId][_offeror];
    Listing memory targetListing = listings[_listingId];
    require(
      _currency == targetOffer.currency &&
        _pricePerToken == targetOffer.pricePerToken,
      "!PRICE"
    );
    require(targetOffer.expirationTimestamp > block.timestamp, "EXPIRED");
    delete offers[_listingId][_offeror];

    executeSale(
      targetListing,
      _offeror,
      _offeror,
      targetOffer.currency,
      targetOffer.pricePerToken * targetOffer.quantityWanted,
      targetOffer.quantityWanted
    );
  }

  function offer(
    uint256 _listingId,
    uint256 _quantityWanted,
    address _currency,
    uint256 _pricePerToken,
    uint256 _expirationTimestamp
  ) external payable override nonReentrant onlyExistingListing(_listingId) {
    Listing memory targetListing = listings[_listingId];
    require(
      targetListing.endTime > block.timestamp &&
        targetListing.startTime < block.timestamp,
      " Inactive listing"
    );
    Offer memory newOffer = Offer({
      listingId: _listingId,
      offeror: _msgSender(),
      quantityWanted: _quantityWanted,
      currency: _currency,
      pricePerToken: _pricePerToken,
      expirationTimestamp: _expirationTimestamp
    });

    if (targetListing.listingType == ListingType.Auction) {
      require(
        newOffer.currency == targetListing.currency,
        "must use approved currency to bid"
      );
      require(newOffer.pricePerToken != 0, "bidding zero amount");
      newOffer.quantityWanted = getSafeQuantity(
        targetListing.tokenType,
        targetListing.quantity
      );
      handleBid(targetListing, newOffer);
    } else if (targetListing.listingType == ListingType.Direct) {
      require(msg.value == 0, "No value needed");
      newOffer.currency = _currency == CurrencyTransferLib.NATIVE_TOKEN
        ? nativeTokenWrapper
        : _currency;
      newOffer.quantityWanted = getSafeQuantity(
        targetListing.tokenType,
        _quantityWanted
      );

      handleOffer(targetListing, newOffer);
    }
  }

  /// @dev Processes an incoming bid in an auction.
  function handleBid(
    Listing memory _targetListing,
    Offer memory _incomingBid
  ) internal {
    Offer memory currentWinningBid = winningBid[_targetListing.listingId];
    uint256 currentOfferAmount = currentWinningBid.pricePerToken *
      currentWinningBid.quantityWanted;
    uint256 incomingOfferAmount = _incomingBid.pricePerToken *
      _incomingBid.quantityWanted;
    address _nativeTokenWrapper = nativeTokenWrapper;

    // Close auction and execute sale if there's a buyout price and incoming offer amount is buyout price.
    if (
      _targetListing.buyoutPricePerToken > 0 &&
      incomingOfferAmount >=
      _targetListing.buyoutPricePerToken * _targetListing.quantity
    ) {
      _closeAuctionForBidder(_targetListing, _incomingBid);
    } else {
      /**
       *      If there's an existng winning bid, incoming bid amount must be bid buffer % greater.
       *      Else, bid amount must be at least as great as reserve price
       */
      require(
        isNewWinningBid(
          _targetListing.reservePricePerToken * _targetListing.quantity,
          currentOfferAmount,
          incomingOfferAmount
        ),
        "not winning bid."
      );

      // Update the winning bid and listing's end time before external contract calls.
      winningBid[_targetListing.listingId] = _incomingBid;

      if (_targetListing.endTime - block.timestamp <= timeBuffer) {
        _targetListing.endTime += timeBuffer;
        listings[_targetListing.listingId] = _targetListing;
      }
    }

    // Payout previous highest bid.
    if (currentWinningBid.offeror != address(0) && currentOfferAmount > 0) {
      CurrencyTransferLib.transferCurrencyWithWrapper(
        _targetListing.currency,
        address(this),
        currentWinningBid.offeror,
        currentOfferAmount,
        _nativeTokenWrapper
      );
    }

    // Collect incoming bid
    CurrencyTransferLib.transferCurrencyWithWrapper(
      _targetListing.currency,
      _incomingBid.offeror,
      address(this),
      incomingOfferAmount,
      _nativeTokenWrapper
    );

    emit NewOffer(
      _targetListing.listingId,
      _incomingBid.offeror,
      _targetListing.listingType,
      _incomingBid.quantityWanted,
      _incomingBid.pricePerToken * _incomingBid.quantityWanted,
      _incomingBid.currency
    );
  }

  /// @dev Checks whether an incoming bid is the new current highest bid.
  function isNewWinningBid(
    uint256 _reserveAmount,
    uint256 _currentWinningBidAmount,
    uint256 _incomingBidAmount
  ) internal view returns (bool isValidNewBid) {
    if (_currentWinningBidAmount == 0) {
      isValidNewBid = _incomingBidAmount >= _reserveAmount;
    } else {
      isValidNewBid = (_incomingBidAmount > _currentWinningBidAmount &&
        ((_incomingBidAmount - _currentWinningBidAmount) * MAX_BPS) /
          _currentWinningBidAmount >=
        bidBufferBps);
    }
  }

  /// @dev Closes an auction for the winning bidder; distributes auction items to the winning bidder.
  function _closeAuctionForBidder(
    Listing memory _targetListing,
    Offer memory _winningBid
  ) internal {
    uint256 quantityToSend = _winningBid.quantityWanted;

    _targetListing.endTime = block.timestamp;
    _winningBid.quantityWanted = 0;

    winningBid[_targetListing.listingId] = _winningBid;
    listings[_targetListing.listingId] = _targetListing;

    transferListingTokens(
      address(this),
      _winningBid.offeror,
      quantityToSend,
      _targetListing
    );

    emit AuctionClosed(
      _targetListing.listingId,
      _msgSender(),
      false,
      _targetListing.tokenOwner,
      _winningBid.offeror
    );
  }

  function handleOffer(
    Listing memory _targetListing,
    Offer memory _newOffer
  ) internal {
    require(
      _newOffer.quantityWanted <= _targetListing.quantity &&
        _targetListing.quantity > 0,
      "insufficient tokens in listing."
    );

    validateERC20BalAndAllowance(
      _newOffer.offeror,
      _newOffer.currency,
      _newOffer.pricePerToken * _newOffer.quantityWanted
    );

    offers[_targetListing.listingId][_newOffer.offeror] = _newOffer;

    emit NewOffer(
      _targetListing.listingId,
      _newOffer.offeror,
      _targetListing.listingType,
      _newOffer.quantityWanted,
      _newOffer.pricePerToken * _newOffer.quantityWanted,
      _newOffer.currency
    );
  }

  function executeSale(
    Listing memory _targetListing,
    address _payer,
    address _receiver,
    address _currency,
    uint256 _currencyAmountToTransfer,
    uint256 _listingTokenAmountToTransfer
  ) internal {
    validateDirectListingSale(
      _targetListing,
      _payer,
      _listingTokenAmountToTransfer,
      _currency,
      _currencyAmountToTransfer
    );

    _targetListing.quantity -= _listingTokenAmountToTransfer;
    listings[_targetListing.listingId] = _targetListing;

    payout(
      _payer,
      _targetListing.tokenOwner,
      _currency,
      _currencyAmountToTransfer,
      _targetListing
    );
    transferListingTokens(
      _targetListing.tokenOwner,
      _receiver,
      _listingTokenAmountToTransfer,
      _targetListing
    );

    emit NewSale(
      _targetListing.listingId,
      _targetListing.assetContract,
      _targetListing.tokenOwner,
      _receiver,
      _listingTokenAmountToTransfer,
      _currencyAmountToTransfer
    );
  }

  /// @dev Pays out stakeholders in a sale.
  function payout(
    address _payer,
    address _payee,
    address _currencyToUse,
    uint256 _totalPayoutAmount,
    Listing memory _listing
  ) internal {
    uint256 platformFeeCut = (_totalPayoutAmount * platformFeeBps) / MAX_BPS;

    uint256 royaltyCut;
    address royaltyRecipient;

    // Distribute royalties. See Sushiswap's https://github.com/sushiswap/shoyu/blob/master/contracts/base/BaseExchange.sol#L296
    try
      IERC2981(_listing.assetContract).royaltyInfo(
        _listing.tokenId,
        _totalPayoutAmount
      )
    returns (address royaltyFeeRecipient, uint256 royaltyFeeAmount) {
      if (royaltyFeeRecipient != address(0) && royaltyFeeAmount > 0) {
        require(
          royaltyFeeAmount + platformFeeCut <= _totalPayoutAmount,
          "fees exceed the price"
        );
        royaltyRecipient = royaltyFeeRecipient;
        royaltyCut = royaltyFeeAmount;
      }
    } catch {}

    // Distribute price to token owner
    address _nativeTokenWrapper = nativeTokenWrapper;

    CurrencyTransferLib.transferCurrencyWithWrapper(
      _currencyToUse,
      _payer,
      platformFeeRecipient,
      platformFeeCut,
      _nativeTokenWrapper
    );
    CurrencyTransferLib.transferCurrencyWithWrapper(
      _currencyToUse,
      _payer,
      royaltyRecipient,
      royaltyCut,
      _nativeTokenWrapper
    );
    CurrencyTransferLib.transferCurrencyWithWrapper(
      _currencyToUse,
      _payer,
      _payee,
      _totalPayoutAmount - (platformFeeCut + royaltyCut),
      _nativeTokenWrapper
    );
  }

  function validateDirectListingSale(
    Listing memory _listing,
    address _payer,
    uint256 _quantityToBuy,
    address _currency,
    uint256 settledTotalPrice
  ) internal {
    require(
      _listing.listingType == ListingType.Direct,
      " Cannot buy from listing"
    );

    require(
      _listing.quantity > 0 &&
        _quantityToBuy > 0 &&
        _quantityToBuy <= _listing.quantity,
      "Invalid amount of tokens"
    );
    require(
      block.timestamp < _listing.endTime &&
        block.timestamp > _listing.startTime,
      "Not within sale window"
    );
    if (_currency == CurrencyTransferLib.NATIVE_TOKEN) {
      require(msg.value == settledTotalPrice, "msg.value != price");
    } else {
      validateERC20BalAndAllowance(_payer, _currency, settledTotalPrice);
    }
  }

  function validateERC20BalAndAllowance(
    address _addressToCheck,
    address _currency,
    uint256 _currencyAmountToCheckAgainst
  ) internal view {
    require(
      IERC20(_currency).balanceOf(_addressToCheck) >=
        _currencyAmountToCheckAgainst &&
        IERC20(_currency).allowance(_addressToCheck, address(this)) >=
        _currencyAmountToCheckAgainst,
      "!BAL20"
    );
  }

  function transferListingTokens(
    address _from,
    address _to,
    uint256 _quantity,
    Listing memory _listing
  ) internal {
    if (_listing.tokenType == TokenType.ERC1155) {
      IERC1155(_listing.assetContract).safeTransferFrom(
        _from,
        _to,
        _listing.tokenId,
        _quantity,
        ""
      );
    } else if (_listing.tokenType == TokenType.ERC721) {
      IERC721A(_listing.assetContract).safeTransferFrom(
        _from,
        _to,
        _listing.tokenId,
        ""
      );
    }
  }

  function getTokenType(
    address _assetContract
  ) internal view returns (TokenType tokenType) {
    if (IERC165(_assetContract).supportsInterface(type(IERC1155).interfaceId)) {
      tokenType = TokenType.ERC1155;
    } else if (
      IERC165(_assetContract).supportsInterface(type(IERC721A).interfaceId)
    ) {
      tokenType = TokenType.ERC721;
    }
  }

  function getSafeQuantity(
    TokenType _tokenType,
    uint256 _quantityToCheck
  ) internal pure returns (uint256 safeQuantity) {
    if (_quantityToCheck == 0) {
      safeQuantity = 0;
    } else {
      safeQuantity = _tokenType == TokenType.ERC721 ? 1 : _quantityToCheck;
    }
  }

  function validateOwnershipAndApproval(
    address _tokenOwner,
    address _assetContract,
    uint256 _tokenId,
    uint256 _quantity,
    TokenType _tokenType
  ) internal view {
    address market = address(this);
    bool isValid;
    if (_tokenType == TokenType.ERC1155) {
      isValid =
        IERC1155(_assetContract).balanceOf(_tokenOwner, _tokenId) >=
        _quantity &&
        IERC1155(_assetContract).isApprovedForAll(_tokenOwner, market);
    } else if (_tokenType == TokenType.ERC721) {
      isValid =
        IERC721A(_assetContract).ownerOf(_tokenId) == _tokenOwner &&
        (IERC721A(_assetContract).getApproved(_tokenId) == market ||
          IERC721A(_assetContract).isApprovedForAll(_tokenOwner, market));
    }
    require(isValid, "error validateOwnershipAndApproval");
  }

  function closeAuction(
    uint256 _listingId,
    address _closeFor
  ) external override nonReentrant onlyExistingListing(_listingId) {
    Listing memory targetListing = listings[_listingId];

    require(
      targetListing.listingType == ListingType.Auction,
      "not an auction."
    );

    Offer memory targetBid = winningBid[_listingId];

    // Cancel auction if (1) auction hasn't started, or (2) auction doesn't have any bids.
    bool toCancel = targetListing.startTime > block.timestamp ||
      targetBid.offeror == address(0);

    if (toCancel) {
      // cancel auction listing owner check
      _cancelAuction(targetListing);
    } else {
      require(
        targetListing.endTime < block.timestamp,
        "cannot close auction before it has ended."
      );

      // No `else if` to let auction close in 1 tx when targetListing.tokenOwner == targetBid.offeror.
      if (_closeFor == targetListing.tokenOwner) {
        _closeAuctionForAuctionCreator(targetListing, targetBid);
      }

      if (_closeFor == targetBid.offeror) {
        _closeAuctionForBidder(targetListing, targetBid);
      }
    }
  }

  function _closeAuctionForAuctionCreator(
    Listing memory _targetListing,
    Offer memory _winningBid
  ) internal {
    uint256 payoutAmount = _winningBid.pricePerToken * _targetListing.quantity;

    _targetListing.quantity = 0;
    _targetListing.endTime = block.timestamp;
    listings[_targetListing.listingId] = _targetListing;

    _winningBid.pricePerToken = 0;
    winningBid[_targetListing.listingId] = _winningBid;

    payout(
      address(this),
      _targetListing.tokenOwner,
      _targetListing.currency,
      payoutAmount,
      _targetListing
    );

    emit AuctionClosed(
      _targetListing.listingId,
      _msgSender(),
      false,
      _targetListing.tokenOwner,
      _winningBid.offeror
    );
  }

  /// @dev Cancels an auction.
  function _cancelAuction(Listing memory _targetListing) internal {
    require(
      listings[_targetListing.listingId].tokenOwner == _msgSender(),
      "caller is not the listing creator."
    );

    delete listings[_targetListing.listingId];

    transferListingTokens(
      address(this),
      _targetListing.tokenOwner,
      _targetListing.quantity,
      _targetListing
    );

    emit AuctionClosed(
      _targetListing.listingId,
      _msgSender(),
      true,
      _targetListing.tokenOwner,
      address(0)
    );
  }

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function getPlaformFeeInfo()
    external
    view
    override
    returns (address, uint16)
  {}

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(IERC165) returns (bool) {
    return
      interfaceId == type(IERC1155Receiver).interfaceId ||
      interfaceId == type(IERC721Receiver).interfaceId;
  }

  function getPlatformFeeInfo() external view returns (address, uint16) {
    return (platformFeeRecipient, uint16(platformFeeBps));
  }

  function setPlatformFeeInfo(
    address _platformFeeRecipient,
    uint256 _platformFeeBps
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_platformFeeBps <= MAX_BPS, "bps <= 10000.");

    platformFeeBps = uint64(_platformFeeBps);
    platformFeeRecipient = _platformFeeRecipient;

    emit PlatformFeeUpdated(_platformFeeRecipient, _platformFeeBps);
  }

  /// @dev Lets a contract admin set auction buffers.
  function setAuctionBuffers(
    uint256 _timeBuffer,
    uint256 _bidBufferBps
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    require(_bidBufferBps < MAX_BPS, "invalid BPS.");

    timeBuffer = uint64(_timeBuffer);
    bidBufferBps = uint64(_bidBufferBps);

    emit AuctionBuffersUpdated(_timeBuffer, _bidBufferBps);
  }

  function setContractURI(
    string calldata _uri
  ) external onlyRole(DEFAULT_ADMIN_ROLE) {
    contractURI = _uri;
  }
}
