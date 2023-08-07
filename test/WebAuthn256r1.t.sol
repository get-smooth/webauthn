// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Test } from "../lib/forge-std/src/Test.sol";
import { WebAuthn256r1 } from "../src/WebAuthn256r1.sol";

contract ContractTestVerify is Test {
    WebAuthn256r1 internal implem;

    function setUp() external {
        implem = new WebAuthn256r1();
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

contract ContractTestVerifyPrecomputation is Test {
    WebAuthn256r1 internal implem;
    // the address where the the precomputed table will live
    address private precomputeAddress;

    function setUp() external {
        implem = new WebAuthn256r1();
        precomputeAddress = vm.addr(42);
    }

    /// @notice precumpute a shamir table of 256 points for a given pubKey
    /// @dev this function execute a JS package listed in the package.json file
    /// @param qx the x coordinate of the public key
    /// @param qy the y coordinate of the public key
    /// @return precompute the precomputed table as a bytes
    function _precomputeShamirTable(uint256 qx, uint256 qy) private returns (bytes memory precompute) {
        // Precompute a 8 dimensional table for Shamir's trick from c0 and c1
        // and return the table as a bytes
        string[] memory inputs = new string[](4);
        inputs[0] = "npx";
        inputs[1] = "@0x90d2b2b7fb7599eebb6e7a32980857d8/secp256r1-computation";
        inputs[2] = vm.toString(qx);
        inputs[3] = vm.toString(qy);
        precompute = vm.ffi(inputs);
    }

    /// @notice Modifier for generating the precomputed table and storing it in the precompiled contract
    /// @dev Uses the `_precomputeShamirTable(<qx>,<qy>)` function to generate the precomputed table
    modifier _preparePrecomputeTable(uint256 qx, uint256 qy) {
        // generate the precomputed table
        bytes memory precompute = _precomputeShamirTable(qx, qy);

        // set the precomputed points as the bytecode of the target contract
        vm.etch(precomputeAddress, precompute);

        // run the test
        _;

        // unset the bytecode of the target contract
        vm.etch(precomputeAddress, hex"00");
    }

    function test_VerifyPrecomput()
        public
        _preparePrecomputeTable(
            114_874_632_398_302_156_264_159_990_279_427_641_021_947_882_640_101_801_130_664_833_947_273_521_181_002,
            32_136_952_818_958_550_240_756_825_111_900_051_564_117_520_891_182_470_183_735_244_184_006_536_587_423
        )
    {
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
                // address where the precompute table lives
                precomputeAddress
            )
        );
    }
}
