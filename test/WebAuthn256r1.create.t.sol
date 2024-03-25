// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test, stdJson } from "../lib/forge-std/src/Test.sol";
import { WebAuthnWrapper } from "./WebAuthnWrapper.sol";

contract WebAuthn256r1Test__Create is Test {
    using stdJson for string;

    WebAuthnWrapper internal implem;
    uint256 internal fixturesNb;

    function setUp() external {
        // deploy a wrapper contract for the library
        implem = new WebAuthnWrapper();

        // load the fixtures from the fixtures.create.json file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/fixtures.create.json");
        string memory json = vm.readFile(path);

        // store the number of fixtures
        bytes memory fixturesNbEncoded = json.parseRaw(".length");
        fixturesNb = abi.decode(fixturesNbEncoded, (uint256));
    }

    /// forge-config: default.fuzz.runs = 50
    /// forge-config: ci.fuzz.runs = 100
    function test_VerifyAValidCreateCorrectly(uint256 identifier) external {
        // it verify a valid create correctly

        identifier = bound(identifier, 0, fixturesNb - 1);

        // load the fixtures from the credentials.json file
        string memory root = vm.projectRoot();
        string memory path = string.concat(root, "/test/fixtures/fixtures.create.json");
        string memory json = vm.readFile(path);

        bytes memory clientDataJSON;
        bytes memory challenge;
        bytes memory authData;
        uint256 qx;
        uint256 qy;
        uint256 r;
        uint256 s;

        // load a random credential from the JSON file
        string memory fixturesId = string.concat(".data[", vm.toString(identifier), "]");
        emit log_named_string("fixturesId", fixturesId);

        {
            // load the clientDataJSON
            bytes memory credentialsResponseEncoded =
                json.parseRaw(string.concat(fixturesId, ".response.clientDataJSON"));
            clientDataJSON = abi.decode(credentialsResponseEncoded, (bytes));
        }

        {
            // load the client challenge from the client data JSON
            bytes memory challengeEncoded =
                json.parseRaw(string.concat(fixturesId, ".responseDecoded.ClientDataJSON.challenge"));
            challenge = abi.decode(challengeEncoded, (bytes));
        }

        {
            // load the auth data from the client data JSON
            bytes memory authDataEncoded = json.parseRaw(string.concat(fixturesId, ".response.authData"));
            authData = abi.decode(authDataEncoded, (bytes));
        }

        {
            // load qx
            qx = json.readUint(string.concat(fixturesId, ".responseDecoded.AttestationObject.authData.pubKeyX"));
        }

        {
            // load qy
            qy = json.readUint(string.concat(fixturesId, ".responseDecoded.AttestationObject.authData.pubKeyY"));
        }

        {
            // load R
            string memory key = ".responseDecoded.AttestationObject.attStmt.r";
            r = json.readUint(string.concat(fixturesId, key));
        }

        {
            // load S
            string memory key = ".responseDecoded.AttestationObject.attStmt.s";
            s = json.readUint(string.concat(fixturesId, key));
        }

        assertTrue(implem.verify(authData, clientDataJSON, challenge, r, s, qx, qy));
    }
}
