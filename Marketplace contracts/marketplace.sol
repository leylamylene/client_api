// SPDX-Licence-Identifier : UNLICENCED
pragma solidity ^0.8.19;

/// @author Laila El hajjamy, thirdweb
// change this later with ERC1155A if needed and all its occurences
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "./IMarketplace.sol";
import "../main-contracts/extension/Permissions.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../main-contracts/eip/IERC721A.sol";

contract Marketplace is
  IPlatformFee,
  IMarketplace,
  Permissions,
  IERC165,
  IERC721Receiver,
  IERC1155Receiver
{
  using SafeCast for uint256;

  uint256 public totalListings;

  string public contractURI;

  address private platformFeeRecipient;
  bytes32 private constant LISTER_ROLE = keccak256("LISTER_ROLE");
  bytes32 private constant ASSET_ROLE = keccak256("ASSET_ROLE");

  uint64 public constant MAX_BPS = 10_000;

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

  constructor() {}

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

    // Must validate ownership and approval of the new quantity of tokens for direct listing.
    if (targetListing.quantity != safeNewQuantity) {
      // Transfer all escrowed tokens back to the lister, to be reflected in the lister's
      // balance for the upcoming ownership and approval check.
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

  function buy(
    uint256 _listingId,
    address _buyFor,
    uint256 _quantity,
    address _currency,
    uint256 _totalPrice
  ) external payable {}

  function offer(
    uint256 _listingId,
    uint256 _quantityWanted,
    address _currency,
    uint256 _pricePerToken,
    uint256 _expirationTimestamp
  ) external payable {}

  function acceptOffer(
    uint256 _listingId,
    address _offeror,
    address _currency,
    uint256 _totalPrice
  ) external {}

  function closeAuction(uint256 _listingId, address _closeFor) external {}

  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function getPlaformFeeInfo()
    external
    view
    override
    returns (address, uint16)
  {}

  function setPlatformFeeInfo(
    address _platfromFeeRecipient,
    uint256 _platformFeeBps
  ) external override {}

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(IERC165) returns (bool) {
    return
      interfaceId == type(IERC1155Receiver).interfaceId ||
      interfaceId == type(IERC721Receiver).interfaceId;
  }
}
