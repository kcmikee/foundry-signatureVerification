
/** 
 *  SourceUnit: /Users/kachi/Downloads/Web3Bridge/wk11/signatureVerification/src/Token.sol
*/

////// SPDX-License-Identifier-FLATTEN-SUPPRESS-WARNING: MIT
pragma solidity ^0.8.19;

////import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Web3CXIToken is ERC20 {
    constructor() ERC20("Web3CXI", "WCXI") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }
}

