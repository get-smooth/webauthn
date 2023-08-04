// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

// import { Base64 } from "../lib/solady/src/utils/Base64.sol";
import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";

error InvalidAuthenticatorData();
error InvalidClientData();

/// dev: this implementation assumes the caller check if User Presence (0x01) or User Verification (0x04) are set
library WebAuthn {
    function generateMessage(
        bytes1 authenticatorDataFlagMask,
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 clientChallengeOffset
    )
        internal
        pure
        returns (bytes32)
    {
        unchecked {
            // Let the caller check if User Presence (0x01) or User Verification (0x04) are set
            if ((authenticatorData[32] & authenticatorDataFlagMask) != authenticatorDataFlagMask) {
                revert InvalidAuthenticatorData();
            }

            // TODO: Pass non-encode challenge? Convert the challenge to `bytes memory` and encode it to Base64
            // bytes memory challengeEncoded = bytes(Base64.encode(abi.encodePacked(clientChallenge), true, true));

            // Extract the challenge from the client data and hash it
            bytes32 challengeHashed =
                keccak256(clientData[clientChallengeOffset:(clientChallengeOffset + clientChallenge.length)]);

            // hash the encoded challenge and check both challenges are equal
            if (keccak256(clientChallenge) != challengeHashed) {
                revert InvalidClientData();
            }

            // Verify the signature over sha256(authenticatorData || sha256(clientData))
            return sha256(abi.encodePacked(authenticatorData, sha256(clientData)));
        }
    }

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
        internal
        returns (bool)
    {
        unchecked {
            // Verify the signature over sha256(authenticatorData || sha256(clientData))
            bytes32 message = generateMessage(
                authenticatorDataFlagMask, authenticatorData, clientData, clientChallenge, clientChallengeOffset
            );

            return ECDSA256r1.verify(message, r, s, qx, qy);
        }
    }
}
