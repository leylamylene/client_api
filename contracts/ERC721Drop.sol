// SPDX-License-Identifier: Apache 2.0
pragma solidity ^0.8.0;

/// @author Laila E l Hajjamy, thirdweb

import "./ERC721A.sol";
import "./ContractMetaData.sol";

import "./Ownable.sol";

import "./Royalty.sol";

import "./BatchMintMetaData.sol";

import "./PrimarySale.sol";

import "./LazyMint.sol";

import "./DelayedReveal.sol";

import "./PlatformFee.sol";

import "./DropSinglePhase.sol";
import "./Multicall.sol";
import "./Strings.sol";

import {CurrencyTransferLib} from "./CurrencyTransferLib.sol";

contract ERC721Drop is
  ERC721A,
  ContractMetaData,
  Multicall,
  Ownable,
  Royalty,
  BatchMintMetaData,
  PrimarySale,
  LazyMint,
  DelayedReveal,
  DropSinglePhase,
  PlatformFee
{
  using Strings for uint256;

  // setApprovalForAll(operator, true) to let the market transfers nfts

  function init(
    string memory _name,
    string memory _symbol,
    address _defaultAdmin,
    address _royaltyRecipient,
    uint128 _royaltyBps,
    address _primarySaleRecipient,
    address operator
  ) public payable initializer {
    initialize(_name, _symbol);
    _setupOwner(_defaultAdmin);
    _setupDefaultRoyaltyInfo(_royaltyRecipient, _royaltyBps);
    _setupPrimarySaleRecipient(_primarySaleRecipient);
    setApprovalForAll(operator, true);
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

  function supportsInterface(
    bytes4 interfaceId
  ) public view virtual override(ERC721A, IERC165) returns (bool) {
    return
      interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
      interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
      interfaceId == 0x5b5e139f || // ERC165 Interface ID for ERC721Metadata
      interfaceId == type(IERC2981).interfaceId; // ERC165 ID for ERC2981
  }

  function lazyMint(
    uint256 _amount,
    string calldata _baseURIForTokens,
    bytes calldata _data
  ) public override returns (uint256 batchId) {
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
    uint256 _currentIndex = _nextTokenId();
    return _currentIndex;
  }

  function reveal(
    uint256 _index,
    bytes calldata _key
  ) public virtual override returns (string memory revealedURI) {
    require(_canReveal(), "Not authorized");
    uint256 batchId = getBatchIdAtIndex(_index);
    revealedURI = getRevealURI(batchId, _key);

    _setEncryptedData(batchId, "");
    _setBaseURI(batchId, revealedURI);

    emit TokenURIRevealed(_index, revealedURI);
  }

  function burn(uint256 _tokenId) external virtual {
    _burn(_tokenId, true);
  }

  function _beforeClaim(
    address,
    uint256 _quantity,
    address,
    uint256,
    AllowlistProof calldata,
    bytes memory
  ) internal view virtual override {
    uint256 _currentIndex = _nextTokenId();

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
    if (_currency == CurrencyTransferLib.NATIVE_TOKEN) {
      validMsgValue = msg.value == totalPrice;
    } else {
      validMsgValue = msg.value == 0;
    }
    require(validMsgValue, "Invalid msg value");

    address saleRecipient = _primarySaleRecipient == address(0)
      ? primarySaleRecipient()
      : _primarySaleRecipient;

    CurrencyTransferLib.transferCurrency(
      _currency,
      _msgSender(),
      getPlatformFeeRecipient(),
      getPlatformFeeBps()
    );
    CurrencyTransferLib.transferCurrency(
      _currency,
      _msgSender(),
      saleRecipient,
      totalPrice - getPlatformFeeBps()
    );
  }

  /**
   * @dev Transfers the NFTs being claimed.
   *
   * @param _to                    The address to which the NFTs are being transferred.
   * @param _quantityBeingClaimed  The quantity of NFTs being claimed.
   */
  function _transferTokensOnClaim(
    address _to,
    uint256 _quantityBeingClaimed
  ) internal virtual override returns (uint256 startTokenId) {
    uint256 _currentIndex = _nextTokenId();

    startTokenId = _currentIndex;
    _safeMint(_to, _quantityBeingClaimed);
  }

  /// @dev Checks whether primary sale recipient can be set in the given execution context.
  function _canSetPrimarySaleRecipient()
    internal
    view
    virtual
    override
    returns (bool)
  {
    return msg.sender == owner();
  }

  /// @dev Checks whether owner can be set in the given execution context.
  function _canSetOwner() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  /// @dev Checks whether royalty info can be set in the given execution context.
  function _canSetRoyaltyInfo() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  /// @dev Checks whether contract metadata can be set in the given execution context.
  function _canSetContractURI() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  /// @dev Checks whether platform fee info can be set in the given execution context.
  function _canSetClaimConditions()
    internal
    view
    virtual
    override
    returns (bool)
  {
    return msg.sender == owner();
  }

  /// @dev Returns whether lazy minting can be done in the given execution context.
  function _canLazyMint() internal view virtual override returns (bool) {
    return msg.sender == owner();
  }

  /// @dev Checks whether NFTs can be revealed in the given execution context.
  function _canReveal() internal view virtual returns (bool) {
    return msg.sender == owner();
  }

  /*///////////////////////////////////////////////////////////////
                        Miscellaneous
    //////////////////////////////////////////////////////////////*/

  function _canSetPlatformFeeInfo() internal view override returns (bool) {
    return msg.sender == owner();
  }

  function _dropMsgSender() internal view virtual override returns (address) {
    return msg.sender;
  }

  /// @notice Returns the sender in the given execution context.
  function _msgSender() internal view override(Multicall) returns (address) {
    return msg.sender;
  }
}
