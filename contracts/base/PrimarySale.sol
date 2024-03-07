// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

/// @author Laila El Hajjamy



abstract contract PrimarySale {
  event PrimarySaleRecipientUpdated(address indexed recipient);

  error PrimarySaleUnauthorized();

  error PrimarySaleInvalidRecipient(address recipient);

  address private recipient;

  function primarySaleRecipient() public view returns (address) {
    return recipient;
  }


  function setPrimarySaleRecipient(address _saleRecipient) external {
    if (!_canSetPrimarySaleRecipient()) {
      revert PrimarySaleUnauthorized();
    }
    _setupPrimarySaleRecipient(_saleRecipient);
  }

  function _setupPrimarySaleRecipient(address _saleRecipient) internal {
    if (_saleRecipient == address(0)) {
      revert PrimarySaleInvalidRecipient(_saleRecipient);
    }

    recipient = _saleRecipient;
    emit PrimarySaleRecipientUpdated(_saleRecipient);
  }

  function _canSetPrimarySaleRecipient() internal view virtual returns (bool);
}
