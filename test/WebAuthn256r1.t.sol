// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { WebAuthnWrapper } from "./WebAuthnWrapper.sol";
import { WebAuthn256r1 } from "src/WebAuthn256r1.sol";

struct Fixtures {
    bytes1 authenticatorDataFlagMask;
    bytes authenticatorData;
    bytes clientData;
    bytes clientChallenge;
    uint256 clientChallengeOffset;
}

contract ContractTestVerify is Test {
    bytes1 internal constant MASK_ACCEPT_UP = 0x01;
    bytes1 internal constant MASK_ACCEPT_UV = 0x04;
    bytes1 internal constant MASK_ACCEPT_BOTH = 0x05;
    WebAuthnWrapper internal implem;

    // TODO: Add more fixtures
    Fixtures internal validFixtures = Fixtures({
        authenticatorDataFlagMask: 0x01,
        authenticatorData: hex"f8e4b678e1c62f7355266eaa4dc1148573440937063a46d848da1e25babbd20b010000004d",
        clientData: hex"7b2274797065223a22776562617574686e2e676574222c226368616c6c656e67"
            hex"65223a224e546f2d3161424547526e78786a6d6b61544865687972444e583369"
            hex"7a6c7169316f776d4f643955474a30222c226f726967696e223a226874747073"
            hex"3a2f2f66726573682e6c65646765722e636f6d222c2263726f73734f726967696e223a66616c73657d",
        clientChallenge: hex"353a3ed5a0441919f1c639a46931de872ac3357de2ce5aa2d68c2639df54189d",
        clientChallengeOffset: 0x24
    });

    function setUp() external {
        implem = new WebAuthnWrapper();
    }

    function test_GenerateMessage() external {
        bytes32 message = implem._generateMessage(
            validFixtures.authenticatorDataFlagMask,
            validFixtures.authenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );

        assertEq(message, 0x4bfd0c06e1609b41d94e18b705de3163f6bf61fa44dcb8127c94bab7ba55fb9c);
    }

    function test_AuthenticatorDataFlagMaskUPCorrect() external view {
        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the user presence flag in the valid authenticator data
        validAuthenticatorData[32] = 0x01;

        implem._generateMessage(
            MASK_ACCEPT_UP,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function testFuzz_RevertWhen_AuthenticatorDataFlagMaskUPIncorrect(bytes1 incorrectFlag) external {
        // make sure the fuzzed flag is incorrect for the UP mask
        vm.assume(MASK_ACCEPT_UP & incorrectFlag == 0);
        vm.expectRevert(WebAuthn256r1.InvalidAuthenticatorData.selector);

        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the incorrect flag in the valid authenticator data
        validAuthenticatorData[32] = incorrectFlag;

        implem._generateMessage(
            MASK_ACCEPT_UP,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function test_AuthenticatorDataFlagMaskUVCorrect() external view {
        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the user validation flag in the valid authenticator data
        validAuthenticatorData[32] = 0x04;

        implem._generateMessage(
            MASK_ACCEPT_UV,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function testFuzz_RevertWhen_AuthenticatorDataFlagMaskUVIncorrect(bytes1 incorrectFlag) external {
        // make sure the fuzzed flag is incorrect for the UV mask
        vm.assume(MASK_ACCEPT_UV & incorrectFlag == 0);
        vm.expectRevert(WebAuthn256r1.InvalidAuthenticatorData.selector);

        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the incorrect flag in the valid authenticator data
        validAuthenticatorData[32] = incorrectFlag;

        implem._generateMessage(
            MASK_ACCEPT_UV,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function test_AuthenticatorDataFlagMaskBothCorrect() external view {
        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the user presence flag in the valid authenticator data
        validAuthenticatorData[32] = 0x01;

        implem._generateMessage(
            MASK_ACCEPT_BOTH,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );

        // set the user validation flag in the valid authenticator data
        validAuthenticatorData[32] = 0x04;

        implem._generateMessage(
            MASK_ACCEPT_BOTH,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function testFuzz_RevertWhen_AuthenticatorDataFlagMaskBothIncorrect(bytes1 incorrectFlag) external {
        // make sure the fuzzed flag neither valid the UP mask nor the UV mask
        vm.assume(MASK_ACCEPT_BOTH & incorrectFlag == 0);
        vm.expectRevert(WebAuthn256r1.InvalidAuthenticatorData.selector);

        bytes memory validAuthenticatorData = validFixtures.authenticatorData;

        // set the incorrect flag in the valid authenticator data
        validAuthenticatorData[32] = incorrectFlag;

        implem._generateMessage(
            MASK_ACCEPT_BOTH,
            validAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    // @dev: this call validates the check of the authenticator data length works (>33)
    function testFuzz_RevertWhen_AuthenticatorDataTooSmall(bytes32 tooSmallAuthenticatorData) external {
        vm.expectRevert();

        implem._generateMessage(
            MASK_ACCEPT_BOTH,
            abi.encodePacked(tooSmallAuthenticatorData),
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function test_AuthenticatorDataNeverTooBig() external view {
        bytes memory bigAuthenticatorData = abi.encodePacked(
            validFixtures.authenticatorData, validFixtures.authenticatorData, validFixtures.authenticatorData
        );

        implem._generateMessage(
            0x01,
            bigAuthenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        );
    }

    function testFuzz_RevertWhen_ClientDataIncorrect(bytes calldata incorrectClientData) external {
        // Exclude valid value from the fuzzing
        // @dev: As you read this check, you're probably thinking that the probability of this happening
        //       is absolutely zero, and you'd be right. But Foundry's fuzzing engine seems to be far from
        //       perfect, which means that this case happens far more often than we imagine, and I don't know why.
        // vm.assume(keccak256(incorrectClientData) != keccak256(validFixtures.clientData));
        vm.expectRevert();

        try implem._generateMessage(
            validFixtures.authenticatorDataFlagMask,
            validFixtures.authenticatorData,
            incorrectClientData,
            validFixtures.clientChallenge,
            validFixtures.clientChallengeOffset
        ) { } catch Error(string memory reason) {
            // This block catches failing revert() and require()
            // In our case, there is two possible valid revert reasons:
            // 1.The value of the client has a length lower than the indexes used to read the challenge. In that case,
            //   an out-of-bound is triggered by the EVM and the transaction revert.
            // 2.The client data is simply not valid, meaning it doesn't pass the check in the contract

            // Here we check the transaction reverted because of one of the two allowed scenarios
            if (
                bytes4(keccak256(bytes(reason))) != WebAuthn256r1.InvalidClientData.selector
                    || keccak256(bytes(reason)) != keccak256("EvmError: Revert")
            ) {
                // If it's not the case, fail the test
                fail("Unknown reverted error");
            }
        }
    }

    function testFuzz_RevertWhen_ClientChallengeIncorrect(bytes calldata incorrectClientChallenge) external {
        // This scenario is tested by `testFuzz_RevertWhen_ClientChallengeIsNull`
        vm.assume(incorrectClientChallenge.length > 0);
        // Exclude valid value from the fuzzing
        // @dev: As you read this check, you're probably thinking that the probability of this happening
        //       is absolutely zero, and you'd be right. But Foundry's fuzzing engine seems to be far from
        //       perfect, which means that this case happens far more often than we imagine, and I don't know why.
        vm.assume(keccak256(incorrectClientChallenge) != keccak256(validFixtures.clientChallenge));
        vm.expectRevert();

        try implem._generateMessage(
            validFixtures.authenticatorDataFlagMask,
            validFixtures.authenticatorData,
            validFixtures.clientData,
            incorrectClientChallenge,
            validFixtures.clientChallengeOffset
        ) { } catch Error(string memory reason) {
            // This block catches failing revert() and require()
            // In our case, there is two possible valid revert reasons:
            // 1.The calculus of the end index overflows meaning we try to access a chunk of memory
            //   by passing an end index lower than the start index. In this case, the EVM revert without reason
            // 2.The calculus of the end index doesn't overflow but the end index is incorrect to the challenge check.
            //   In this case, the EVM revert with the selector (first 4-bytes of the signature) of our custom Error.

            // Here we check the transaction reverted because of one of the two allowed scenarios
            if (
                bytes4(keccak256(bytes(reason))) != WebAuthn256r1.InvalidClientData.selector
                    || keccak256(bytes(reason)) != keccak256("EvmError: Revert")
            ) {
                // If it's not the case, fail the test
                fail("Unknown reverted error");
            }
        }
    }

    // @dev: By providing a null client challenge and an offset of 0, it was possible to pass the
    //       challenge check without providing a valid challenge in the contract. This test ensure
    //       that this scenario is not possible anymore
    function testFuzz_RevertWhen_ClientChallengeIsNull() external {
        vm.expectRevert(WebAuthn256r1.InvalidChallenge.selector);

        implem._generateMessage(
            validFixtures.authenticatorDataFlagMask, validFixtures.authenticatorData, validFixtures.clientData, "", 0
        );
    }

    function testFuzz_RevertWhen_ClientChallengeOffsetIncorrect(uint256 incorrectClientChallengeOffset) external {
        // exclude valid data flag values from the fuzzing
        vm.assume(incorrectClientChallengeOffset != validFixtures.clientChallengeOffset);

        // tell the test runner to expect a revert in the next call
        vm.expectRevert();

        try implem._generateMessage(
            validFixtures.authenticatorDataFlagMask,
            validFixtures.authenticatorData,
            validFixtures.clientData,
            validFixtures.clientChallenge,
            incorrectClientChallengeOffset
        ) { } catch Error(string memory reason) {
            // This block catches failing revert() and require()
            // In our case, there is two possible valid revert reasons:
            // 1.The calculus of the end index overflows meaning we try to access a chunk of memory
            //   by passing an end index lower than the start index. In this case, the EVM revert without reason
            // 2.The calculus of the end index doesn't overflow but the end index is incorrect to the challenge check.
            //   In this case, the EVM revert with the selector (first 4-bytes of the signature) of our custom Error.

            // Here we check the transaction reverted because of one of the two allowed scenarios
            if (
                bytes4(keccak256(bytes(reason))) != WebAuthn256r1.InvalidClientData.selector
                    || keccak256(bytes(reason)) != keccak256("EvmError: Revert")
            ) {
                // If it's not the case, fail the test
                fail("Unknown reverted error");
            }
        } catch {
            // Fail the test if the transaction revert due to something else than revert() or require()
            fail("Unknown reverted error");
        }
    }

    function test_Verify() public {
        assertTrue(
            implem.verify(
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
                0x24,
                // r
                45_847_212_378_479_006_099_766_816_358_861_726_414_873_720_355_505_495_069_909_394_794_949_093_093_607,
                // s
                55_835_259_151_215_769_394_881_684_156_457_977_412_783_812_617_123_006_733_908_193_526_332_337_539_398,
                // qx
                114_874_632_398_302_156_264_159_990_279_427_641_021_947_882_640_101_801_130_664_833_947_273_521_181_002,
                // qy
                32_136_952_818_958_550_240_756_825_111_900_051_564_117_520_891_182_470_183_735_244_184_006_536_587_423
            )
        );
    }
}
