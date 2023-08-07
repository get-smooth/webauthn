// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Base64 } from "../lib/solady/src/utils/Base64.sol";
import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";

error InvalidAuthenticatorData();
error InvalidClientData();

/// @title A library to verify ECDSA signature though WebAuthn on the secp256r1 curve
/// @dev This implementation assumes the caller check if User Presence (0x01) or User Verification (0x04) are set
library WebAuthn {
    /// @notice Validate the webauthn data and generate the signature message needed to recover
    /// @dev You may probably ask why we encode the challenge in base64 on-chain instead of
    ///      of sending it already encoded to save some gas. This library is opiniated and
    ///      it assumes that it is used in the context of Account Abstraction. In this context,
    ///      valuable informations required to proceed the transaction will be stored in the challenge
    ///      meaning we need the challenge in clear to use it later in the flow. That's why we decided to
    ///      encode it here.
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

            // Encode the client challenge in base64 and explicitly convert it to bytes
            bytes memory challengeEncoded = bytes(Base64.encode(clientChallenge, true, true));

            // Extract the challenge from the client data and hash it
            bytes32 challengeHashed =
                keccak256(clientData[clientChallengeOffset:(clientChallengeOffset + challengeEncoded.length)]);

            // Hash the encoded challenge and check both challenges are equal
            if (keccak256(challengeEncoded) != challengeHashed) {
                revert InvalidClientData();
            }

            // Verify the signature over sha256(authenticatorData || sha256(clientData))
            return sha256(abi.encodePacked(authenticatorData, sha256(clientData)));
        }
    }

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
        internal
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
