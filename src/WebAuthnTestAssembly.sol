// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

// import { Base64 } from "../lib/solady/src/utils/Base64.sol";
// import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";

// error InvalidAuthenticatorData();
// error InvalidClientData();

// // equivelent to `clientData[clientChallengeOffset:clientChallengeOffset + bytes(challengeEncoded).length]`
// // (200 gas more expensive)
// // bytes memory challengeExtracted = new bytes(
// //     bytes(challengeEncoded).length
// // );
// // assembly {
// //     calldatacopy( // copy from calldata to memory
// //         add(challengeExtracted, 32), // destOffset
// //         add(clientData.offset, clientChallengeOffset), // offset
// //         mload(challengeExtracted) // size
// //     )
// // }

// // equivalent to `keccak256(abi.encodePacked(challengeExtracted));` (350 gas more expensive)
// // bytes32 moreData;

// library WebAuthnImplementation {
//     function format(
//         bytes calldata authenticatorData,
//         bytes1 authenticatorDataFlagMask,
//         bytes calldata clientData,
//         bytes32 clientChallenge,
//         uint256 clientChallengeOffset
//     )
//         internal
//         returns (bytes32 result)
//     {
//         {
//             /// @DEV: Check if User Presence (0x01) or User Verification (0x04) are set
//             if ((authenticatorData[32] & authenticatorDataFlagMask) != authenticatorDataFlagMask) {
//                 revert InvalidAuthenticatorData();
//             }

//             /// @DEV: Verify that clientData commits to the expected client challenge
//             string memory challengeEncoded = Base64.encode(abi.encodePacked(clientChallenge), true, true);
//             assembly ("memory-safe") {
//                 // equivelent to `clientData[clientChallengeOffset:clientChallengeOffset +
//                 // bytes(challengeEncoded).length]`
//                 // (200 gas more expensive)
//                 let challengeExtracted := mload(0x40)
//                 // store challengeExtracted length -- 1 slot expansion
//                 mstore(challengeExtracted, mload(challengeEncoded))

//                 calldatacopy( // copy from calldata to memory
//                     add(challengeExtracted, 0x20), // destOffset -- 1 slot expansion
//                     add(clientData.offset, clientChallengeOffset), // offset
//                     mload(challengeExtracted) // size
//                 )

//                 let challengeExtractedHash := keccak256(add(challengeExtracted, 32), mload(challengeExtracted))
//                 let challengeEncodedHash := keccak256(add(challengeEncoded, 32), mload(challengeEncoded))

//                 if iszero(eq(challengeExtractedHash, challengeEncodedHash)) {
//                     // override the first scratch space slot to not paying the gas expansion
//                     mstore(0x00, 0xebab5d29)
//                     revert(0x00, 0x20)
//                 }
//             }
//         }

//         assembly ("memory-safe") {
//             let verifyData := mload(0x40)
//             // store authenticatorData length -- 1 slot expansion -- override challengeExtracted's length
//             mstore(verifyData, add(authenticatorData.length, 0x20))

//             calldatacopy( // copy from calldata to memory
//                 add(verifyData, 0x20), // destOffset -- n slot expansions -- override challengeExtracted's value
//                 authenticatorData.offset, // offset
//                 authenticatorData.length // size
//             )

//             // let clientDataHash := add(mload(0x40), 0x80)
//             // assembly {
//             // make sure not erase verifyData's length and value -- 1 slot expansion
//             pop(
//                 staticcall(
//                     gas(),
//                     0x02,
//                     clientData.offset,
//                     clientData.length,
//                     // add(verifyData, add(authenticatorData.length, 0x20)),
//                     add(verifyData, authenticatorData.length),
//                     0x20
//                 )
//             )
//             // }

//             // mstore(0x80, clientDataHash)

//             // result := 0x01

//             // TODO: check success
//             //              gas   addr   argsOffset             argsSize         retOffset  retSize
//             pop(staticcall(gas(), 0x02, add(verifyData, 0x20), mload(verifyData), 0x00, 0x20))
//             result := mload(0x00)
//         }

//         // Verify the signature over sha256(authenticatorData || sha256(clientData))
//         // bytes memory verifyData = new bytes(authenticatorData.length + 32);
//         // assembly {
//         //     calldatacopy( // copy from calldata to memory
//         //         add(verifyData, 32), // destOffset
//         //         authenticatorData.offset, // offset
//         //         authenticatorData.length // size
//         //     )
//         // }
//         // bytes32 more = sha256(clientData);
//         // assembly {
//         //     mstore(add(verifyData, add(authenticatorData.length, 32)), more)
//         // }

//         // return sha256(verifyData);
//     }\

//     /// note: this implementation assumes the caller check if User Presence (0x01) or User Verification (0x04) are
// set
//     function verify(
//         bytes calldata authenticatorData,
//         bytes1 authenticatorDataFlagMask,
//         bytes calldata clientData,
//         bytes32 clientChallenge,
//         uint256 clientChallengeOffset,
//         uint256 r,
//         uint256 s,
//         uint256 qx,
//         uint256 qy
//     )
//         external
//         returns (bool)
//     {
//         bytes32 message =
//             format(authenticatorData, authenticatorDataFlagMask, clientData, clientChallenge, clientChallengeOffset);

//         return ECDSA256r1.verify(message, r, s, qx, qy);
//     }
// }
