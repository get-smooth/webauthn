// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "forge-std/Test.sol";
import { WebAuthn } from "../src/WebAuthn.sol";

contract WebAuthnImplementation {
    function verify(
        bytes calldata authenticatorData,
        bytes1 authenticatorDataFlagMask,
        bytes calldata clientData,
        bytes32 clientChallenge,
        uint256 clientChallengeOffset,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        external
        returns (bool)
    {
        return WebAuthn.verify(
            authenticatorData,
            authenticatorDataFlagMask,
            clientData,
            clientChallenge,
            clientChallengeOffset,
            r,
            s,
            qx,
            qy
        );
    }
}

contract ContractTest is Test {
    WebAuthnImplementation internal implem;

    function setUp() external {
        implem = new WebAuthnImplementation();
    }

    function test_Webauthn() public {
        bytes memory authenticatorData =
            hex"f8e4b678e1c62f7355266eaa4dc1148573440937063a46d848da1e25babbd20b" hex"010000004d";
        bytes1 authenticatorDataFlagMask = 0x01;
        bytes memory clientData = hex"7b2274797065223a22776562617574686e2e676574222c226368616c6c656e67"
            hex"65223a224e546f2d3161424547526e78786a6d6b61544865687972444e583369"
            hex"7a6c7169316f776d4f643955474a30222c226f726967696e223a226874747073"
            hex"3a2f2f66726573682e6c65646765722e636f6d222c2263726f73734f726967696e223a66616c73657d";
        bytes32 clientChallenge = hex"353a3ed5a0441919f1c639a46931de872ac3357de2ce5aa2d68c2639df54189d";
        uint256 clientChallengeDataOffset = 0x24; // 36
        uint256 r =
            45_847_212_378_479_006_099_766_816_358_861_726_414_873_720_355_505_495_069_909_394_794_949_093_093_607;
        uint256 s =
            55_835_259_151_215_769_394_881_684_156_457_977_412_783_812_617_123_006_733_908_193_526_332_337_539_398;
        uint256 qx =
            114_874_632_398_302_156_264_159_990_279_427_641_021_947_882_640_101_801_130_664_833_947_273_521_181_002;
        uint256 qy =
            32_136_952_818_958_550_240_756_825_111_900_051_564_117_520_891_182_470_183_735_244_184_006_536_587_423;

        assertTrue(
            implem.verify(
                authenticatorData,
                authenticatorDataFlagMask,
                clientData,
                clientChallenge,
                clientChallengeDataOffset,
                r,
                s,
                qx,
                qy
            )
        );
    }
}
