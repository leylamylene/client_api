// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../contracts/base/Royalty.sol";
import "../contracts/base/DelayedReveal.sol";
import "../contracts/base/LazyMint.sol";
import "../contracts/base/DropSinglePhase.sol";
import "../contracts/base/PrimarySale.sol";
import "../contracts/base/IERC20.sol";
import "../contracts/utils/String.sol";

contract MyERC721Drop is
  ERC721,
  Ownable,
  Royalty,
  BatchMintMetadata,
  PrimarySale,
  LazyMint,
  DelayedReveal,
  DropSinglePhase
{
  using String for uint256;
  address private _owner;
  event OwnerChanged(address prevOwner, address newOwner);
  uint256 internal _currentIndex;
  event TokenURIRevealed(uint256 indexed index, string revealedURI);
  address public constant NATIVE_TOKEN =
    0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  constructor(
    address _defaultAdmin,
    string memory _name,
    string memory _symbol,
    address _royaltyRecipient,
    uint128 _royaltyBps,
    address _primarySaleRecipient
  ) ERC721(_name, _symbol) Ownable(msg.sender) {
    _setOwner(_defaultAdmin);
    _setDefaultRoyaltyInfo(_royaltyRecipient, _royaltyBps);
    _setupPrimarySaleRecipient(_primarySaleRecipient);
    _currentIndex = _startTokenId();
  }

  function _startTokenId() internal view virtual returns (uint256) {
    return 0;
  }

  function tokenURI(
    uint256 _tokenId
  ) public view virtual override returns (string memory) {
    (uint256 batchId, ) = _getBatchId(_tokenId);
    string memory batchUri = _getBaseURI(_tokenId);

    if (isEncryptedBatch(batchId)) {
      return string(abi.encodePacked(batchUri, "0"));
    } else {
      return string(abi.encodePacked(batchUri, _tokenId.toString()));
    }
  }

  function lazyMint(
    uint256 _amount,
    string calldata _baseURIForTokens,
    bytes calldata _data
  ) public virtual override returns (uint256 batchId) {
    if (_data.length > 0) {
      (bytes memory encryptedURI, bytes32 provenanceHash) = abi.decode(
        _data,
        (bytes, bytes32)
      );
      if (encryptedURI.length != 0 && provenanceHash != "") {
        _setEncryptedData(nextTokenIdToLazyMint + _amount, _data);
      }
    }

    return LazyMint.lazyMint(_amount, _baseURIForTokens, _data);
  }

  function nextTokenIdToMint() public view virtual returns (uint256) {
    return nextTokenIdToLazyMint;
  }

  function nextTokenIdToClaim() public view virtual returns (uint256) {
    return _currentIndex;
  }

  function reveal(
    uint256 _index,
    bytes calldata _key
  ) public virtual returns (string memory revealedURI) {
    require(_canReveal(), "Not authorized");

    uint256 batchId = getBatchIdAtIndex(_index);
    revealedURI = getRevealURI(batchId, _key);

    _setEncryptedData(batchId, "");
    _setBaseURI(batchId, revealedURI);

    emit TokenURIRevealed(_index, revealedURI);
  }

  function _beforeClaim(
    address,
    uint256 _quantity,
    address,
    uint256,
    AllowlistProof calldata,
    bytes memory
  ) internal view virtual override {
    if (_currentIndex + _quantity > nextTokenIdToLazyMint) {
      revert("Not enough minted tokens");
    }
  }

  function _collectPriceOnClaim(
    address _primarySaleRecipient,
    uint256 _quantityToClaim,
    address _currency,
    uint256 _pricePerToken
  ) internal virtual override {
    if (_pricePerToken == 0) {
      require(msg.value == 0, "!Value");
      return;
    }

    uint256 totalPrice = _quantityToClaim * _pricePerToken;

    bool validMsgValue;
    if (_currency == NATIVE_TOKEN) {
      validMsgValue = msg.value == totalPrice;
    } else {
      validMsgValue = msg.value == 0;
    }
    require(validMsgValue, "Invalid msg value");

    address saleRecipient = _primarySaleRecipient == address(0)
      ? primarySaleRecipient()
      : _primarySaleRecipient;
    transferCurrency(_currency, msg.sender, saleRecipient, totalPrice);
  }

  function transferCurrency(
    address _currency,
    address _from,
    address _to,
    uint256 _amount
  ) internal {
    if (_amount == 0) {
      return;
    }

    if (_currency == NATIVE_TOKEN) {
      safeTransferNativeToken(_to, _amount);
    } else {
      safeTransferERC20(_currency, _from, _to, _amount);
    }
  }

  function safeTransferERC20(
    address _currency,
    address _from,
    address _to,
    uint256 _amount
  ) internal {
    if (_from == _to) {
      return;
    }

    safeTransferFrom(_from, _to, _amount);
  }

  function safeTransferNativeToken(address to, uint256 value) internal {
    (bool success, ) = to.call{value: value}("");
    if (!success) {
      revert("Transfer native token failed");
    }
  }

  function _transferTokensOnClaim(
    address _to,
    uint256 _quantityBeingClaimed
  ) internal virtual override returns (uint256 startTokenId) {
    startTokenId = _currentIndex;
    _safeMint(_to, _quantityBeingClaimed);
  }

  function _canSetPrimarySaleRecipient()
    internal
    view
    virtual
    override
    returns (bool)
  {
    return msg.sender == owner();
  }

  function _canSetOwner() internal view virtual returns (bool) {
    return msg.sender == owner();
  }

  function burn(uint256 _tokenId) external virtual {
    _burn(_tokenId);
  }

  function _setOwner(address _newOwner) internal {
    address _prevOwner = _owner;
    _owner = _newOwner;
    emit OwnerChanged(_prevOwner, _newOwner);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(ERC721) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function _canSetRoyaltyInfo() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  function _canSetContractURI() internal view virtual returns (bool) {
    return msg.sender == owner();
  }

  function _canSetClaimConditions()
    internal
    view
    virtual
    override
    returns (bool)
  {
    return msg.sender == owner();
  }

  function _canLazyMint() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  function _canReveal() internal view virtual returns (bool) {
    return msg.sender == owner();
  }

  function _dropMsgSender() internal view virtual override returns (address) {
    return msg.sender;
  }

  function _msgSender() internal view override returns (address) {
    return msg.sender;
  }
}
