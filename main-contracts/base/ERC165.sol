// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v5.0.0 (utils/introspection/ERC165.sol)


pragma solidity ^0.8.20;
import "../eip/IERC165.sol";


abstract contract ERC165 is IERC165 {
    
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}




