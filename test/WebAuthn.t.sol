// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { WebAuthn } from "../src/WebAuthn.sol";

contract WebAuthnImplementation is WebAuthn {
    function _generateMessage(
        bytes1 authenticatorDataFlagMask,
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 clientChallengeOffset
    )
        external
        pure
        returns (bytes32)
    {
        return generateMessage(
            authenticatorDataFlagMask, authenticatorData, clientData, clientChallenge, clientChallengeOffset
        );
    }
}

contract ContractTest is Test {
    WebAuthnImplementation internal implem;

    function setUp() external {
        implem = new WebAuthnImplementation();
    }

    function test_GenerateMessage() public {
        bytes32 message = implem._generateMessage(
            // authenticatorDataFlagMask
            0x01,
            // authenticatorData
            hex"f8e4b678e1c62f7355266eaa4dc1148573440937063a46d848da1e25babbd20b010000004d",
            // clientData
            hex"7b2274797065223a22776562617574686e2e676574222c226368616c6c656e67"
            hex"65223a224e546f2d3161424547526e78786a6d6b61544865687972444e583369"
            hex"7a6c7169316f776d4f643955474a30222c226f726967696e223a226874747073"
            hex"3a2f2f66726573682e6c65646765722e636f6d222c2263726f73734f726967696e223a66616c73657d",
            // clientChallenge
            hex"353a3ed5a0441919f1c639a46931de872ac3357de2ce5aa2d68c2639df54189d",
            // clientChallengeOffset
            0x24
        );

        assertEq(message, 0x4bfd0c06e1609b41d94e18b705de3163f6bf61fa44dcb8127c94bab7ba55fb9c);
    }
}
