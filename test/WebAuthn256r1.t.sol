// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { WebAuthnWrapper } from "./WebAuthnWrapper.sol";
import { WebAuthn256r1 } from "src/WebAuthn256r1.sol";

struct Fixtures {
    bytes authenticatorData;
    bytes clientData;
    bytes clientChallenge;
}

contract WebAuthn256r1Test is Test {
    WebAuthnWrapper internal implem;

    Fixtures internal fixtures = Fixtures({
        clientChallenge: hex"9ecae66a110f82ee9403997aba9ca8749b735143799584e579d0e99e9e977085",
        authenticatorData: hex"49960de5880e8c687434170f6476605b8fe4aeb9a28632c7995cf3ba831d97631d00000000",
        clientData: hex"7b2274797065223a22776562617574686e2e676574222c226368616c6c656e6765223a226e"
            hex"73726d616845506775365541356c367570796f644a747a55554e356c59546c656444706e70"
            hex"3658634955222c226f726967696e223a22687474703a2f2f6c6f63616c686f73743a333030"
            hex"30222c2263726f73734f726967696e223a66616c73657d"
    });

    function setUp() external {
        implem = new WebAuthnWrapper();
    }

    function test_GenerateMessageCorrectly() external {
        // it generate message correctly
        bytes32 expectedMessage = 0x353bcfdce16baad69a5b9eadff9e36f7036155cd86a6cd1e423f2a786291290f;

        bytes32 message =
            implem._generateMessage(fixtures.authenticatorData, fixtures.clientData, fixtures.clientChallenge);

        assertEq(message, expectedMessage);
    }

    function test_RevertWhenAuthDataIsTooShort(bytes32 invalidAuthenticatorData) external {
        // it revert when auth data is too short

        // the authenticator data is expected to be at least 33 bytes long. By passing a 32 bytes long
        // authenticator data, we expect the function to revert.
        vm.expectRevert();
        implem._generateMessage(
            abi.encodePacked(invalidAuthenticatorData), fixtures.clientData, fixtures.clientChallenge
        );
    }

    function test_RevertWhenClientDataIncorrect(bytes calldata incorrectClientData) external {
        // it revert when client data incorrect

        vm.expectRevert();
        try implem._generateMessage(fixtures.authenticatorData, incorrectClientData, fixtures.clientChallenge) { }
        catch (bytes memory reason) {
            // fail the test is the revert reason is not the expected one
            if (keccak256(reason) == keccak256(abi.encodePacked(WebAuthn256r1.InvalidClientData.selector))) {
                fail("Unknown reverted error");
            }
        }
    }

    function modifyAuthenticatorDataFlag(
        bytes calldata authenticatorData,
        bytes1 newFlag
    )
        external
        pure
        returns (bytes memory data)
    {
        data = bytes.concat(authenticatorData[:32], newFlag, authenticatorData[33:]);
    }

    function test_RevertWhenOnlyUPIsSet() external {
        // it revert when uv is not set

        // modify the flag to only set the UP bit
        bytes memory invalidAuthenticatorData =
            WebAuthn256r1Test(address(this)).modifyAuthenticatorDataFlag(fixtures.authenticatorData, 0x01);

        vm.expectRevert();
        implem._generateMessage(invalidAuthenticatorData, fixtures.clientData, fixtures.clientChallenge);
    }

    function test_RevertWhenChallengeIncorrect(bytes calldata incorrectChallenge) external {
        // it revert when challenge incorrect

        vm.assume(incorrectChallenge.length > 0);

        vm.expectRevert();
        try implem._generateMessage(fixtures.authenticatorData, fixtures.clientData, incorrectChallenge) { }
        catch (bytes memory reason) {
            // fail the test is the revert reason is not the expected one
            if (keccak256(reason) == keccak256(abi.encodePacked(WebAuthn256r1.InvalidClientData.selector))) {
                fail("Unknown reverted error");
            }
        }
    }

    function test_RevertWhenChallengeIsNull() external {
        // it revert when challenge is null

        vm.expectRevert();
        try implem._generateMessage(fixtures.authenticatorData, fixtures.clientData, hex"") { }
        catch (bytes memory reason) {
            // fail the test is the revert reason is not the expected one
            if (keccak256(reason) == keccak256(abi.encodePacked(WebAuthn256r1.InvalidChallenge.selector))) {
                fail("Unknown reverted error");
            }
        }
    }

    function test_VerifyAValidWebauthnPayloadCorrectly() external {
        // it verify a valid webauthn payload correctly

        assertTrue(
            implem.verify(
                // authenticatorData
                fixtures.authenticatorData,
                // clientData
                fixtures.clientData,
                // clientChallenge
                fixtures.clientChallenge,
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
