// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";
import { ECDSA256r1Precompute } from "../lib/secp256r1-verify/src/ECDSA256r1Precompute.sol";
import { WebAuthnBase } from "./WebAuthnBase.sol";

/// @title WebAuthn256r1
/// @notice A library to verify ECDSA signature though WebAuthn on the secp256r1 curve
/// @custom:experimental This is an experimental library.
contract WebAuthn256r1 is WebAuthnBase {
    /// @notice Verify ECDSA signature though WebAuthn on the secp256r1 curve
    function verify(
        bytes1 authenticatorDataFlagMask,
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 clientChallengeOffset,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        external
        returns (bool)
    {
        unchecked {
            bytes32 message = generateMessage(
                authenticatorDataFlagMask, authenticatorData, clientData, clientChallenge, clientChallengeOffset
            );

            return ECDSA256r1.verify(message, r, s, qx, qy);
        }
    }

    /// @notice Verify ECDSA signature though WebAuthn on the secp256r1 curve using a precomputed table
    function verify(
        bytes1 authenticatorDataFlagMask,
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 clientChallengeOffset,
        uint256 r,
        uint256 s,
        address precomputedTable
    )
        external
        returns (bool)
    {
        unchecked {
            bytes32 message = generateMessage(
                authenticatorDataFlagMask, authenticatorData, clientData, clientChallenge, clientChallengeOffset
            );

            return ECDSA256r1Precompute.verify(message, r, s, precomputedTable);
        }
    }
}
