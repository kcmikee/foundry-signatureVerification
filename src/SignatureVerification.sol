// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract SignatureVerification {
    using ECDSA for bytes32;

    IERC20 public token;
    mapping(address => bool) public whitelist;
    mapping(bytes32 => bool) public usedMessages;
    uint256 public claimAmount;

    event TokensClaimed(address indexed claimer, uint256 amount);
    event AddressWhitelisted(address indexed account);

    constructor(address _token, uint256 _claimAmount) {
        token = IERC20(_token);
        claimAmount = _claimAmount;
    }

    function addToWhitelist(address[] calldata addresses) external {
        require(msg.sender != address(0), "Invalid address");
        for (uint i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
            emit AddressWhitelisted(addresses[i]);
        }
    }

    function claimTokens(bytes32 messageHash, bytes memory signature) external {
        require(msg.sender != address(0), "Invalid address");
        require(!usedMessages[messageHash], "Message already used");
        require(whitelist[msg.sender], "Address not whitelisted");

        address signer = messageHash.recover(signature);
        require(signer == msg.sender, "Invalid signature");

        usedMessages[messageHash] = true;
        require(token.transfer(msg.sender, claimAmount), "Transfer failed");

        emit TokensClaimed(msg.sender, claimAmount);
    }

    function isWhitelisted(address account) external view returns (bool) {
        return whitelist[account];
    }
}
