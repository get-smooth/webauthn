// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { WebAuthnWrapper } from "./WebAuthnWrapper.sol";

// TODO: generate get flow's fixtures
contract WebAuthn256r1Test__Get is Test {
    WebAuthnWrapper internal implem;
    uint256 internal fixturesNb;

    function setUp() external {
        // deploy a wrapper contract for the library
        implem = new WebAuthnWrapper();
    }

    function test_VerifyAValidCreateCorrectly() external {
        // it verify a valid get correctly

        assertTrue(
            implem.verify(
                // authenticatorData
                hex"49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97631d00000000",
                // clientData
                hex"7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a226e"
                hex"73726d616845506775365541356c367570796f644a747a55554e356c59546c656444706e70"
                hex"3658634955222c226f726967696e223a22687474703a2f2f6c6f63616c686f73743a333030"
                hex"30222c2263726f73734f726967696e223a66616c73657d",
                // clientChallenge
                hex"9ecae66a110f82ee9403997aba9ca8749b735143799584e579d0e99e9e977085",
                // r
                0x637f5e51e5e288310958cca253c12ef632869af03b2d398afb00c7a2ddcfcdd7,
                // s
                0x0b29ee7b84c8faf6b452e4700d6bd55f93525f1e0be0800e0c1b37986d23717f,
                // qx
                0xa33941ccf9b4eac590cda2457256babd0dca8379389b7e6612ab8fba34372a5b,
                // qy
                0xabe3b0cc14188c0ea28775b79120495f504df1e0f937bcbe88b2ee00f0d22c75
            )
        );
    }
}
