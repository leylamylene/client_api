// SPDX-Licence-Identifier : UNLICENCED
pragma solidity ^0.8.19;


/// @author Laila El hajjamy
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Marketplace {
  using SafeCast for uint256;

  address private admin;
  uint public marketFee = 5;
  mapping(uint => address) public recipients;
  mapping(uint => uint) public fees;
  uint256 public recipientsCount;
  mapping(uint => SellList) public sales;
  uint256 public salesId;
  mapping(uint => mapping(uint => Offer)) public offers;
  mapping(uint => uint) public offersCount;
  mapping(address => uint) public escrowAmount;

  mapping(uint => Auction) public auctions;
  uint256 public auctionId;

  struct SellList {
    address seller;
    address token;
    uint256 tokenId;
    uint256 amountOfToken;
    uint256 deadline;
    uint256 price;
    bool isSold;
  }

  struct Offer {
    address offeror;
    uint256 offeredPrice;
    bool isAccepted;
  }

  struct Auction {
    address creator;
    address token;
    address highestBidder;
    uint256 tokenId;
    uint256 amountOftoken;
    uint256 highestBid;
    uint256 startPrice;
    uint256 minIncrement;
    uint256 startDate;
    uint256 duration;
    Action action;
  }

  enum Action {
    RESERVED,
    STARTED
  }

  event SellMade(
    address _seller,
    address _token,
    uint256 _offerId,
    uint256 _tokenId,
    uint256 _amount
  );

  event SellCancelled(
    address _seller,
    address _token,
    uint256 _tokenId,
    uint256 _amountOfToken
  );

  event BuyMade(
    address _buyer,
    address _token,
    uint256 _tokenId,
    uint256 _amountOfToken,
    uint256 _price
  );

  constructor() {
    admin = msg.sender;
  }

  function updateMarketplaceFee(uint256 _newFee) external onlyAdmin {
    marketFee = _newFee;
  }

  modifier onlyAdmin() {
    require(admin == msg.sender, "Only the admin can call this function");
    _;
  }

  function updateFeesAndRecipients(
    address[] memory _recipients,
    uint256[] memory _fees
  ) external onlyAdmin {
    require(
      _recipients.length == _fees.length,
      "recipients list count and fees count should be the same"
    );

    recipientsCount = _fees.length;
    for (uint i = 0; i < recipientsCount; i++) {
      recipients[i] = _recipients[i];
      fees[i] = _fees[i];
    }
  }

  function createList(
    address _token,
    uint256 _tokenId,
    uint256 _amountOftoken,
    uint256 _deadline,
    uint256 _price
  ) external returns (bool) {
    // to verify later if the seller wants to sell a list containing
    require(
      _amountOftoken > 0,
      "The amount of token to sell needs to be greater then 0"
    );
    require(_price > 0, "The full price for tokens needs to be greater than 0");
    require(_deadline > 3600, " The deadline needs to be greater than 1 hour");

    sales[salesId] = SellList(
      msg.sender,
      _token,
      _tokenId,
      _amountOftoken,
      block.timestamp + _deadline,
      _price,
      false
    );

    salesId++;

    emit SellMade(msg.sender, _token, salesId, _tokenId, _amountOftoken);
    return true;
  }

  function buyListToken(uint256 _saleId) external payable returns (bool) {
    require(msg.sender != address(0), "BuyToken : needs to be a valid address");
    require(
      sales[_saleId].isSold != true,
      " BuyToken :This token is already sold"
    );
    require(
      msg.value >= sales[_saleId].price,
      "BuyToken : value needs to be greater or equal to the price"
    );

    uint256 salePrice = sales[_saleId].price;
    uint256 feePrice = (salePrice * marketFee) / 100;

    payable(sales[_saleId].seller).transfer(salePrice - feePrice);

    for (uint i = 0; i < recipientsCount; i++) {
      payable(recipients[i]).transfer((feePrice * fees[i]) / 100);
    }

    IERC1155(sales[_saleId].token).safeTransferFrom(
      sales[_saleId].seller,
      msg.sender,
      sales[_saleId].tokenId,
      sales[_saleId].amountOfToken,
      "0x0"
    );
    return true;
  }

  function cancelList(uint256 _saleId) external returns (bool) {
    require(
      sales[_saleId].seller == msg.sender,
      "Cancel: should be the owner of the sell."
    );
    require(sales[_saleId].isSold != true, "Cancel: already sold.");

    delete sales[_saleId];

    emit SellCancelled(
      sales[_saleId].seller,
      sales[_saleId].token,
      sales[_saleId].tokenId,
      sales[_saleId].amountOfToken
    );

    return true;
  }

  function transfer(
    address _receiver,
    address _token,
    uint256 _tokenId,
    uint256 _amountOfToken
  ) external returns (bool) {
    /* 
            Send ERC1155 token to _receiver wallet
            _amountOfToken to the _receiver
        */
    IERC1155(_token).safeTransferFrom(
      msg.sender,
      _receiver,
      _tokenId,
      _amountOfToken,
      "0x0"
    );

    return true;
  }

  function makeOffer(
    uint256 _saleId,
    uint256 _price
  ) external payable returns (bool) {
    /*
            Check if the msg.value is the same as the _price value of this sell, 
             if the seller is msg.sender
             if it is not sold yet.
        */
    require(msg.value == _price, "makeOffer: msg.value should be the _price");
    require(
      sales[_saleId].seller != msg.sender,
      "makeOffer: seller shouldn't offer"
    );
    require(sales[_saleId].isSold != true, "makeOffer: already sold.");

    /*
            Get the offerCount of this _saleId
        */
    uint256 counter = offersCount[_saleId];

    /*
            Add variables to the OfferData struct with offerAddress, offerPrice, offerAcceptable bool value
        */
    offers[_saleId][counter] = Offer(msg.sender, msg.value, false);

    /*
            The offerCount[_saleId] value add +1
        */
    offersCount[_saleId]++;

    /*
            Add the value to the `escrowAmount[address]`
        */
    escrowAmount[msg.sender] += msg.value;

    return true;
  }

  function acceptOffer(
    uint256 _saleId,
    uint256 _offerCount
  ) external returns (bool) {
    /*
            Get the offer data from _saleId and _offerCount
        */
    Offer memory offer = offers[_saleId][_offerCount];

    /*
            Check if the sale NFTs are not sold
             if the seller is msg.sender
             if it is already accepted
             if offerPrice is larger than escrowAmount
        */
    require(sales[_saleId].isSold != true, "acceptOffer: already sold.");
    require(sales[_saleId].seller == msg.sender, "acceptOffer: not seller");
    require(offer.isAccepted == false, "acceptOffer: already accepted");
    require(
      offer.offeredPrice <= escrowAmount[offer.offeror],
      "acceptOffer: lower amount"
    );

    /*
            Get offerPrice and feePrice from the marketplaceFee
        */
    uint256 offerPrice = offer.offeredPrice;
    uint256 feePrice = (offerPrice * marketFee) / 100;

    /*
            Transfer offerPrice - feePrice to the seller's wallet
        */
    payable(sales[_saleId].seller).transfer(offerPrice - feePrice);

    /*
            Distribution feePrice to the recipients' wallets
        */
    for (uint i = 0; i < recipientsCount; i++) {
      payable(recipients[i]).transfer((feePrice * fees[i]) / 100);
    }

    /*
            Substract the offerPrice from the `escrowAmount[address]`
        */
    escrowAmount[offer.offeror] -= offerPrice;

    /* 
            After we send the Matic to the user, we send
            the amountOfToken to the msg.sender.
        */
    IERC1155(sales[_saleId].token).safeTransferFrom(
      sales[_saleId].seller,
      offer.offeror,
      sales[_saleId].tokenId,
      sales[_saleId].amountOfToken,
      "0x0"
    );

    /*
            Set the offer data as it is accepted
        */
    offers[_saleId][_offerCount].isAccepted = true;

    return true;
  }

  function cancelOffer(
    uint256 _saleId,
    uint256 _offerCount
  ) external returns (bool) {
    /*
            Get the offer data from _saleId and _offerCount
        */
    Offer memory offer = offers[_saleId][_offerCount];

    /*
            Check if the offer's offerAddress is msg.sender
                if the offer is already accepted
                if the offerPrice is larger than the escrowAmount
        */
    require(msg.sender == offer.offeror, "cancelOffer: not offerAddress");
    require(offer.isAccepted == false, "acceptOffer: already accepted");
    // maybe don't need this
    require(
      offer.offeredPrice <= escrowAmount[msg.sender],
      "cancelOffer: lower amount"
    );

    /*
            Transfer offerPrice return to the offerAddress
        */
    payable(offer.offeror).transfer(offer.offeredPrice);

    /*
            Substract the offerPrice from the `escrowAmount[address]`
        */
    escrowAmount[msg.sender] -= offer.offeredPrice;

    /*
            After that checking we can safely delete the offerData
            in our marketplace.
        */
    delete offers[_saleId][_offerCount];

    return true;
  }

  function depositEscrow() external payable returns (bool) {
    /*
            Add the value to the `escrowAmount[address]`
        */
    escrowAmount[msg.sender] += msg.value;

    return true;
  }

  function withdrawEscrow(uint256 _amount) external returns (bool) {
    /*
            The _amount should be smaller than the `escrowAmount[address]` 
        */
    // Should be called by the one we escrowed the amount

    require(_amount < escrowAmount[msg.sender], "withdrawEscrow: lower amount");

    /*
            Transfer _amount to the msg.sender wallet
        */
    payable(msg.sender).transfer(_amount);

    /*
            Substract the _amount from the `escrowAmount[address]`
        */
    escrowAmount[msg.sender] -= _amount;

    return true;
  }

  function createAuction(
    address _token,
    uint256 _tokenId,
    uint256 _amountOfToken,
    uint256 _startPrice,
    uint256 _minIncrement,
    uint256 _startDate,
    uint256 _duration,
    bool _reserved
  ) external returns (bool) {
    require(
      _amountOfToken > 0,
      "createAuction : The amount of token to sell needds to be greater than 0"
    );
    require(
      _startPrice > 0,
      "createAuction: The startPrice for the tokens need to be greater than 0"
    );
    require(
      _duration > 86400,
      "createAuction: The deadline should to be greater than 1 day"
    );
    require(
      _startPrice > 0,
      "createAuction: The start Price should be bigger than 0"
    );
    require(
      _minIncrement > 0,
      "createAuction: The minIncrement should be bigger than 0"
    );
    require(
      _startDate > block.timestamp,
      "createAuction: The start date should be after now"
    );

    Action action;
    if (!_reserved) {
      action = Action.STARTED;
    }

    auctions[auctionId] = Auction(
      msg.sender,
      _token,
      address(0),
      _tokenId,
      _amountOfToken,
      _startPrice - _minIncrement,
      _startPrice,
      _minIncrement,
      _startDate,
      _duration,
      action
    );
    auctionId++;

    return true;
  }

  function placeBid(uint256 _auctionId) external payable returns (bool) {
    /*
            Get the auction data from _aucitonId
        */
    Auction memory auctionInfo = auctions[_auctionId];

    /*
            Check if bidAmount is bigger than the higestBid + minIncrement
                if the creator is msg.sender
                if the bidTime is after the startDate
        */
    require(
      msg.value >= auctionInfo.highestBid + auctionInfo.minIncrement,
      "placeBid: Bid amount should be bigger than highestBid"
    );
    require(msg.sender != auctionInfo.creator, "placeBid: Creator can't bid");
    require(
      block.timestamp >= auctionInfo.startDate,
      "placeBid: Bid should be after the startDate"
    );
    require(
      auctionInfo.action == Action.RESERVED ||
        auctionInfo.startDate + auctionInfo.duration > block.timestamp,
      "placeBid: It is Ended"
    );

    /*
            Send back the highestBid to the highestBidder - who is not zero address
        */
    if (auctionInfo.highestBidder != address(0)) {
      payable(auctionInfo.highestBidder).transfer(auctionInfo.highestBid);
    }

    /*
            If the auction is reserved, set the startDate as now
            action as Action Enum - STARTED
        */
    if (auctionInfo.action == Action.RESERVED) {
      auctions[_auctionId].startDate = block.timestamp;
      auctions[_auctionId].action = Action.STARTED;
    }

    /*
            Set the auctionData's highest bidder as msg.sender - who is the new bidder
                the auctionData's highest bid as msg.value - what is the new bid value
        */
    auctions[_auctionId].highestBidder = msg.sender;
    auctions[_auctionId].highestBid = msg.value;

    return true;
  }

  function cancelAuction(uint256 _auctionId) external returns (bool) {
    /*
            Get the auction data from _auctionId
        */
    Auction memory auctionInfo = auctions[_auctionId];

    /*
            Check if the msg.sender should be the auction's creator 
                if the now time should be after auction's endDate
                if the auction's highestBidder should be zero address
        */
    require(
      msg.sender == auctionInfo.creator,
      "cancelAuction: Only auction creator can cancel it"
    );
    require(
      block.timestamp > auctionInfo.startDate + auctionInfo.duration,
      "cancelAuction: The time should be after endDate"
    );
    require(
      auctionInfo.highestBidder == address(0),
      "cancelAuction: There should be no highestBidder"
    );

    /*
            Delete the auctionData from the blockchain
        */
    delete auctions[_auctionId];

    return true;
  }

  function claimAuction(uint256 _auctionId) external returns (bool) {
    /*
            Get the auction data from _aucitonId
        */
    Auction memory auctionInfo = auctions[_auctionId];

    /*
            Check if the msg.sender should be the highestBidder
                if the now time should be after auction's endDate
                if the auction's highestBidder should be zero address
        */
    require(
      msg.sender == auctionInfo.highestBidder,
      "claimAuction: The msg.sender should be the highest Bidder"
    );
    require(
      block.timestamp > auctionInfo.startDate + auctionInfo.duration,
      "claimAuction: Auction duration didn't finish yet"
    );

    /* 
            Send the amountOfToken to the highest Bidder.
        */
    IERC1155(auctionInfo.token).safeTransferFrom(
      auctionInfo.creator,
      auctionInfo.highestBidder,
      auctionInfo.tokenId,
      auctionInfo.amountOftoken,
      "0x0"
    );

    /*
            Get bidPrice and feePrice from the marketplaceFee
        */
    uint256 bidPrice = auctionInfo.highestBid;
    uint256 feePrice = (bidPrice * marketFee) / 100;

    /*
            Transfer bidPrice-feePrice to the creator's wallet
        */
    payable(auctionInfo.creator).transfer(bidPrice - feePrice);

    /*
            Distribution feePrice to the recipients' wallets
        */
    for (uint i = 0; i < recipientsCount; i++) {
      payable(recipients[i]).transfer((feePrice * fees[i]) / 100);
    }

    return true;
  }
}
