// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author Laila El HAJJAMY

interface IPrimarySale {
  function primarySaleRecipient() external view returns (address);

  function setPrimarySaleRecipient(address _saleRecipient) external;

  event PrimarySaleRecipientUpdate(address indexed recipient);
}
