// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

/// @author thirdweb , Laila El Hajjamy

import "./IPermissions.sol";
import "./Strings.sol";

abstract contract Permissions is IPermissions {
  error PermissionsUnauthorizedAccount(address account, bytes32 neededRole);

  error PermissionsAlreadyGranted(address account, bytes32 role);

  error PermissionsInvalidPermission(address expected, address actual);

  mapping(bytes32 => mapping(address => bool)) private _hasRole;

  mapping(bytes32 => bytes32) private _getRoleAdmin;

  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

  constructor() {}

  modifier onlyRole(bytes32 role) {
    _checkRole(role, msg.sender);
    _;
  }

  function hasRole(
    bytes32 role,
    address account
  ) public view override returns (bool) {
    return _hasRole[role][account];
  }

  function hasRoleWithSwitch(
    bytes32 role,
    address account
  ) public view returns (bool) {
    if (!_hasRole[role][address(0)]) {
      return _hasRole[role][account];
    }

    return true;
  }

  function getRoleAdmin(bytes32 role) external view override returns (bytes32) {
    return _getRoleAdmin[role];
  }

  function grantRole(bytes32 role, address account) public override {
    _checkRole(_getRoleAdmin[role], msg.sender);
    if (_hasRole[role][account]) {
      revert PermissionsAlreadyGranted(account, role);
    }
    _setupRole(role, account);
  }

  function revokeRole(bytes32 role, address account) public override {
    _checkRole(_getRoleAdmin[role], msg.sender);
    _revokeRole(role, account);
  }

  function renounceRole(bytes32 role, address account) public override {
    if (msg.sender != account) {
      revert PermissionsInvalidPermission(msg.sender, account);
    }
    _revokeRole(role, account);
  }

  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
    bytes32 previousAdminRole = _getRoleAdmin[role];
    _getRoleAdmin[role] = adminRole;
    emit RoleAdminChanged(role, previousAdminRole, adminRole);
  }

  function _setupRole(bytes32 role, address account) internal {
    _hasRole[role][account] = true;
    emit RoleGranted(role, account, msg.sender);
  }

  function _revokeRole(bytes32 role, address account) internal {
    _checkRole(role, account);
    delete _hasRole[role][account];
    emit RoleRevoked(role, account, msg.sender);
  }

  function _checkRole(bytes32 role, address account) internal view {
    if (!_hasRole[role][account]) {
      revert PermissionsUnauthorizedAccount(account, role);
    }
  }

  function _checkRoleWithSwitch(bytes32 role, address account) internal view {
    if (!hasRoleWithSwitch(role, account)) {
      revert PermissionsUnauthorizedAccount(account, role);
    }
  }
}
