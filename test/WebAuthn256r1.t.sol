// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test, stdJson } from "../lib/forge-std/src/Test.sol";
import { WebAuthnWrapper } from "./WebAuthnWrapper.sol";
import { WebAuthn256r1 } from "src/WebAuthn256r1.sol";

struct Fixtures {
    bytes attestationObject;
    bytes clientData;
    bytes clientChallenge;
    bytes authData;
}

struct CredentialResponse {
    bytes AttestationObject;
    bytes clientDataJSON;
}

contract WebAuthn256r1Test is Test {
    using stdJson for string;

    WebAuthnWrapper internal implem;
    Fixtures internal fixtures;
    uint256 internal fixturesNb;

    function setUp() external {
        // deploy a wrapper contract for the library
        implem = new WebAuthnWrapper();

        // load the fixtures from the fixtures.create.json file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/fixtures.create.json");
        string memory json = vm.readFile(path);

        // store the number of fixtures
        bytes memory fixturesNbRaw = json.parseRaw(".length");
        fixturesNb = abi.decode(fixturesNbRaw, (uint256));

        // load the response of the first credentials from the json file
        bytes memory credentialsResponseRaw = json.parseRaw(".data[0].response");
        CredentialResponse memory credentialReponse = abi.decode(credentialsResponseRaw, (CredentialResponse));

        // load the client challenge from the client data JSON
        bytes memory challengeRaw = json.parseRaw(".data[0].responseDecoded.ClientDataJSON.challenge");
        bytes memory challenge = abi.decode(challengeRaw, (bytes));

        // load the client challenge from the client data JSON
        bytes memory authDataRaw = json.parseRaw(".data[0].responseDecoded.AttestationObject.authData");
        bytes memory authData = abi.decode(authDataRaw, (bytes));

        // store the fixtures
        fixtures = Fixtures({
            attestationObject: credentialReponse.AttestationObject,
            clientData: credentialReponse.clientDataJSON,
            clientChallenge: challenge,
            authData: authData
        });
    }

    function test_RevertWhenAuthDataIsTooShort(bytes32 invalidAuthData) external {
        // it revert when auth data is too short

        // the authenticator data is expected to be at least 33 bytes long. By passing a 32 bytes long
        // authenticator data, we expect the function to revert.
        vm.expectRevert();
        implem._generateMessage(abi.encodePacked(invalidAuthData), fixtures.clientData, fixtures.clientChallenge);
    }

    function test_RevertWhenClientDataIncorrect(bytes calldata incorrectClientData) external {
        // it revert when client data incorrect

        vm.expectRevert();
        try implem._generateMessage(fixtures.authData, incorrectClientData, fixtures.clientChallenge) { }
        catch (bytes memory reason) {
            // fail the test is the revert reason is not the expected one
            if (keccak256(reason) == keccak256(abi.encodePacked(WebAuthn256r1.InvalidClientData.selector))) {
                fail("Unknown reverted error");
            }
        }
    }

    function _modifyauthDataFlag(bytes calldata authData, bytes1 newFlag) external pure returns (bytes memory data) {
        data = bytes.concat(authData[:32], newFlag, authData[33:]);
    }

    function test_RevertWhenOnlyUPIsSet() external {
        // it revert when uv is not set

        // modify the flag to only set the UP bit
        bytes memory invalidauthData = WebAuthn256r1Test(address(this))._modifyauthDataFlag(fixtures.authData, 0x01);

        vm.expectRevert();
        implem._generateMessage(invalidauthData, fixtures.clientData, fixtures.clientChallenge);
    }

    function test_RevertWhenChallengeIncorrect(bytes calldata incorrectChallenge) external {
        // it revert when challenge incorrect

        vm.assume(incorrectChallenge.length > 0);

        vm.expectRevert();
        try implem._generateMessage(fixtures.authData, fixtures.clientData, incorrectChallenge) { }
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
        try implem._generateMessage(fixtures.authData, fixtures.clientData, hex"") { }
        catch (bytes memory reason) {
            // fail the test is the revert reason is not the expected one
            if (keccak256(reason) == keccak256(abi.encodePacked(WebAuthn256r1.InvalidChallenge.selector))) {
                fail("Unknown reverted error");
            }
        }
    }
}
