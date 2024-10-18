// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/SignatureVerification.sol";
import "../src/Token.sol";

contract SignatureVerificationTest is Test {
    SignatureVerification public verifier;
    Web3CXIToken public token;
    uint256 public constant CLAIM_AMOUNT = 100 * 10 ** 18;

    uint256 private userPrivateKey = 0xA11CE;
    address public user = vm.addr(userPrivateKey);

    function setUp() public {
        token = new Web3CXIToken();
        verifier = new SignatureVerification(address(token), CLAIM_AMOUNT);

        token.transfer(address(verifier), CLAIM_AMOUNT * 10);

        address[] memory addresses = new address[](1);
        addresses[0] = user;
        verifier.addToWhitelist(addresses);
    }

    function testSignatureVerification() public {
        bytes32 messageHash = keccak256("Claim tokens");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(user);

        uint256 initialBalance = token.balanceOf(user);

        verifier.claimTokens(messageHash, signature);

        assertEq(token.balanceOf(user), initialBalance + CLAIM_AMOUNT);

        vm.stopPrank();
    }

    function testCannotClaimTwice() public {
        bytes32 messageHash = keccak256("Claim tokens");
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(user);

        verifier.claimTokens(messageHash, signature);
        vm.expectRevert("Message already used");
        verifier.claimTokens(messageHash, signature);

        vm.stopPrank();
    }

    function testNonWhitelistedCannotClaim() public {
        bytes32 messageHash = keccak256("Claim tokens");
        uint256 randomKey = 0xB0B;
        address randomUser = vm.addr(randomKey);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(randomKey, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        vm.startPrank(randomUser);

        vm.expectRevert("Address not whitelisted");
        verifier.claimTokens(messageHash, signature);

        vm.stopPrank();
    }
}
