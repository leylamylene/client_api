// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy

import "../utils/MerkleProof.sol";

abstract contract DropSinglePhase {
  error DropUnauthorized();

  error DropExceedMaxSupply();

  error DropNoActiveCondition();
  struct AllowlistProof {
    bytes32[] proof;
    uint256 quantityLimitPerWallet;
    uint256 pricePerToken;
    address currency;
  }

  struct ClaimCondition {
    uint256 startTimestamp;
    uint256 maxClaimableSupply;
    uint256 supplyClaimed;
    uint256 quantityLimitPerWallet;
    bytes32 merkleRoot;
    uint256 pricePerToken;
    address currency;
    string metadata;
  }

  event TokensClaimed(
    address indexed claimer,
    address indexed receiver,
    uint256 indexed startTokenId,
    uint256 quantityClaimed
  );

  error DropClaimInvalidTokenPrice(
    address expectedCurrency,
    uint256 expectedPricePerToken,
    address actualCurrency,
    uint256 actualExpectedPricePerToken
  );

  error DropClaimExceedLimit(uint256 expected, uint256 actual);

  error DropClaimExceedMaxSupply(uint256 expected, uint256 actual);

  error DropClaimNotStarted(uint256 expected, uint256 actual);

  ClaimCondition public claimCondition;

  bytes32 private conditionId;

  event ClaimConditionUpdated(ClaimCondition condition, bool resetEligibility);

  mapping(bytes32 => mapping(address => uint256)) private supplyClaimedByWallet;

  function claim(
    address _receiver,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof,
    bytes memory _data
  ) public payable virtual {
    _beforeClaim(
      _receiver,
      _quantity,
      _currency,
      _pricePerToken,
      _allowlistProof,
      _data
    );

    bytes32 activeConditionId = conditionId;

    verifyClaim(
      _dropMsgSender(),
      _quantity,
      _currency,
      _pricePerToken,
      _allowlistProof
    );

    claimCondition.supplyClaimed += _quantity;
    supplyClaimedByWallet[activeConditionId][_dropMsgSender()] += _quantity;

    _collectPriceOnClaim(address(0), _quantity, _currency, _pricePerToken);

    uint256 startTokenId = _transferTokensOnClaim(_receiver, _quantity);

    emit TokensClaimed(_dropMsgSender(), _receiver, startTokenId, _quantity);

    _afterClaim(
      _receiver,
      _quantity,
      _currency,
      _pricePerToken,
      _allowlistProof,
      _data
    );
  }

  function setClaimConditions(
    ClaimCondition calldata _condition,
    bool _resetClaimEligibility
  ) external {
    if (!_canSetClaimConditions()) {
      revert DropUnauthorized();
    }

    bytes32 targetConditionId = conditionId;
    uint256 supplyClaimedAlready = claimCondition.supplyClaimed;

    if (_resetClaimEligibility) {
      supplyClaimedAlready = 0;
      targetConditionId = keccak256(
        abi.encodePacked(_dropMsgSender(), block.number)
      );
    }

    if (supplyClaimedAlready > _condition.maxClaimableSupply) {
      revert DropExceedMaxSupply();
    }

    claimCondition = ClaimCondition({
      startTimestamp: _condition.startTimestamp,
      maxClaimableSupply: _condition.maxClaimableSupply,
      supplyClaimed: supplyClaimedAlready,
      quantityLimitPerWallet: _condition.quantityLimitPerWallet,
      merkleRoot: _condition.merkleRoot,
      pricePerToken: _condition.pricePerToken,
      currency: _condition.currency,
      metadata: _condition.metadata
    });
    conditionId = targetConditionId;

    emit ClaimConditionUpdated(_condition, _resetClaimEligibility);
  }

  function verifyClaim(
    address _claimer,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof
  ) public view virtual returns (bool isOverride) {
    ClaimCondition memory currentClaimPhase = claimCondition;
    uint256 claimLimit = currentClaimPhase.quantityLimitPerWallet;
    uint256 claimPrice = currentClaimPhase.pricePerToken;
    address claimCurrency = currentClaimPhase.currency;

    if (currentClaimPhase.merkleRoot != bytes32(0)) {
      (isOverride, ) = MerkleProof.verify(
        _allowlistProof.proof,
        currentClaimPhase.merkleRoot,
        keccak256(
          abi.encodePacked(
            _claimer,
            _allowlistProof.quantityLimitPerWallet,
            _allowlistProof.pricePerToken,
            _allowlistProof.currency
          )
        )
      );
    }

    if (isOverride) {
      claimLimit = _allowlistProof.quantityLimitPerWallet != 0
        ? _allowlistProof.quantityLimitPerWallet
        : claimLimit;
      claimPrice = _allowlistProof.pricePerToken != type(uint256).max
        ? _allowlistProof.pricePerToken
        : claimPrice;
      claimCurrency = _allowlistProof.pricePerToken != type(uint256).max &&
        _allowlistProof.currency != address(0)
        ? _allowlistProof.currency
        : claimCurrency;
    }

    uint256 _supplyClaimedByWallet = supplyClaimedByWallet[conditionId][
      _claimer
    ];

    if (_currency != claimCurrency || _pricePerToken != claimPrice) {
      revert DropClaimInvalidTokenPrice(
        _currency,
        _pricePerToken,
        claimCurrency,
        claimPrice
      );
    }

    if (_quantity == 0 || (_quantity + _supplyClaimedByWallet > claimLimit)) {
      revert DropClaimExceedLimit(
        claimLimit,
        _quantity + _supplyClaimedByWallet
      );
    }

    if (
      currentClaimPhase.supplyClaimed + _quantity >
      currentClaimPhase.maxClaimableSupply
    ) {
      revert DropClaimExceedMaxSupply(
        currentClaimPhase.maxClaimableSupply,
        currentClaimPhase.supplyClaimed + _quantity
      );
    }

    if (currentClaimPhase.startTimestamp > block.timestamp) {
      revert DropClaimNotStarted(
        currentClaimPhase.startTimestamp,
        block.timestamp
      );
    }
  }

  function getSupplyClaimedByWallet(
    address _claimer
  ) public view returns (uint256) {
    return supplyClaimedByWallet[conditionId][_claimer];
  }

  function _dropMsgSender() internal virtual returns (address) {
    return msg.sender;
  }

  function _beforeClaim(
    address _receiver,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof,
    bytes memory _data
  ) internal virtual {}

  function _afterClaim(
    address _receiver,
    uint256 _quantity,
    address _currency,
    uint256 _pricePerToken,
    AllowlistProof calldata _allowlistProof,
    bytes memory _data
  ) internal virtual {}

  function _collectPriceOnClaim(
    address _primarySaleRecipient,
    uint256 _quantityToClaim,
    address _currency,
    uint256 _pricePerToken
  ) internal virtual;

  function _transferTokensOnClaim(
    address _to,
    uint256 _quantityBeingClaimed
  ) internal virtual returns (uint256 startTokenId);

  function _canSetClaimConditions() internal view virtual returns (bool);
}
