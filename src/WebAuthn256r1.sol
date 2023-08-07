// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";
import { WebAuthn } from "./WebAuthn.sol";

/// @title A library to verify ECDSA signature though WebAuthn on the secp256r1 curve
contract WebAuthn256r1 is WebAuthn {
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
}