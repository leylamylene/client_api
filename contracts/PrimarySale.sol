// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El Hajjamy, thirdweb

import "./IPrimarySale.sol";

abstract contract PrimarySale is IPrimarySale {
  error PrimarySaleUnauthorized();
  error PrimarySaleInvalidRecipient(address recipient);

  // address that receives all primary sales values
  address private recipient;

  function primarySaleRecipient() public view override returns (address) {
    return recipient;
  }

  function setPrimarySaleRecipient(address _saleRecipient) external override {
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
    emit PrimarySaleRecipientUpdate(_saleRecipient);
  }




  function _canSetPrimarySaleRecipient() internal view virtual returns (bool);
}
