// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { BaseScript } from "./BaseScript.s.sol";
import { WebAuthn256r1 } from "../src/WebAuthn256r1.sol";

/// @notice This script deploys the ECDSA256r1 library
contract MyScript is BaseScript {
    function run() external broadcast returns (address addr) {
        // deploy the library contract and return the address
        addr = address(new WebAuthn256r1());
    }
}

/*

    ℹ️ HOW TO USE THIS SCRIPT USING A LEDGER:
    forge script script/DeployWebAuthn.s.sol:MyScript --rpc-url <RPC_URL> --ledger --sender <ACCOUNT_ADDRESS> \
    [--broadcast]


    ℹ️ HOW TO USE THIS SCRIPT WITH AN ARBITRARY PRIVATE KEY (NOT RECOMMENDED):
    PRIVATE_KEY=<PRIVATE_KEY> forge script script/DeployWebAuthn.s.sol:MyScript --rpc-url <RPC_URL> [--broadcast]


    ℹ️ HOW TO USE THIS SCRIPT ON ANVIL IN DEFAULT MODE:
    forge script script/DeployWebAuthn.s.sol:MyScript --rpc-url http://127.0.0.1:8545 --broadcast --sender \
    0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266 --mnemonics "test test test test test test test test test test test junk"


    ℹ️ HOW TO CALL THE LIBRARY ONCE DEPLOYED:
    cast call <CONTRACT_ADDRESS> verify(bytes,bytes1,bytes,bytes32,uint256,uint256,uint256,uint256,uint256)(bool)" \
    <AUTH_DATA_FLAGMASK> <AUTH_DATA> <CLIENT_DATA> <CLIENT_CHALLENGE> <CLIENT_CHALLENGE_OFFSET> \
    <R> <S> <QX> <QY>

    example:
        cast call 0x387ca8d38f379710a3d24d710ba2940787f7b4a1 \
        "verify(bytes1,bytes,bytes,bytes,uint256,uint256,uint256,uint256,uint256)(bool)" \
        0x01 \
        0xf8e4b678e1c62f7355266eaa4dc1148573440937063a46d848da1e25babbd20b010000004d \
        0x7b2274797065223a22776562617574686e2e676574222c226368616c6c656e67\
65223a224e546f2d3161424547526e78786a6d6b61544865687972444e583369\
7a6c7169316f776d4f643955474a30222c226f726967696e223a226874747073\
3a2f2f66726573682e6c65646765722e636f6d222c2263726f73734f726967696e223a66616c73657d\
        353a3ed5a0441919f1c639a46931de872ac3357de2ce5aa2d68c2639df54189d \
        0x24 \
        45847212378479006099766816358861726414873720355505495069909394794949093093607 \
        55835259151215769394881684156457977412783812617123006733908193526332337539398 \
        114874632398302156264159990279427641021947882640101801130664833947273521181002 \
        32136952818958550240756825111900051564117520891182470183735244184006536587423
*/
