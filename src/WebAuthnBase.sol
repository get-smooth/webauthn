// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Base64 } from "../lib/solady/src/utils/Base64.sol";

/// @title WebAuthnBase
/// @notice An abstract contract that validates the WebAuthn data and generates the message to recover
/// @dev This implementation assumes the caller check if User Presence (0x01) or User Verification (0x04) are set
abstract contract WebAuthnBase {
    error InvalidAuthenticatorData();
    error InvalidClientData();
    error InvalidChallenge();

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
            if ((authenticatorData[32] & authenticatorDataFlagMask) == 0) {
                revert InvalidAuthenticatorData();
            }

            // Ensure the client challenge is not null
            if (clientChallenge.length == 0) revert InvalidChallenge();

            // Encode the client challenge in base64 and explicitly convert it to bytes
            bytes memory challengeEncoded = bytes(Base64.encode(clientChallenge, true, true));

            // Extract the challenge from the client data and hash it
            // @dev: we don't need to check the overflow here as the EVM will automatically revert if
            //       `clientChallengeOffset + challengeEncoded.length` overflow. This is because we will
            //       try to access a chunk of memory by passing an end index lower than the start index
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
}
