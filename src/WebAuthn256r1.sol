// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";
import { Base64 } from "../lib/solady/src/utils/Base64.sol";

/// @title WebAuthn256r1
/// @notice A library to verify ECDSA signature though WebAuthn on the secp256r1 curve
/// @custom:experimental This is an experimental library.
library WebAuthn256r1 {
    /// Those are bit masks that can be used to validate the flag in the
    /// authenticator data. The flag is located at byte 32 of the authenticator
    /// data and is used to indicate, among other things, wheter the user's
    /// presence/verification ceremonies have been performed.
    /// This version of the library is opinionated for passkeys that enforce UV.
    ///
    /// Here are some flags you may want to use depending on your needs.
    /// - 0x01: User presence (UP) is required. If the UP flag is not set, revert
    /// - 0x04: User verification (UV) is required. If the UV flag is not set, revert
    /// - 0x05: UV and UP are both accepted. If none of them is set, revert
    ///
    /// Read more about UP here: https://www.w3.org/TR/webauthn-2/#test-of-user-presence
    /// Read more about UV here: https://www.w3.org/TR/webauthn-2/#user-verification
    bytes1 internal constant UP_FLAG_MASK = 0x01;
    bytes1 internal constant UV_FLAG_MASK = 0x04;
    bytes1 internal constant BOTH_FLAG_MASK = 0x05;

    error InvalidAuthenticatorData();
    error InvalidClientData();
    error InvalidChallenge();

    // The offset of the client challenge in the client data. Constant as defined in the specification.
    uint256 private constant CLIENT_CHALLENGE_OFFSET = 0x24;

    /// @notice Validate the webauthn data and generate the signature message needed to recover
    /// @param authenticatorData The authenticator data structure encodes contextual bindings made by the authenticator.
    ///                          Described here: https://www.w3.org/TR/webauthn-2/#authenticator-data
    /// @param clientData      This is the client data that was signed. The client data represents the
    ///                        contextual bindings of both the WebAuthn Relying Party and the client.
    ///                        Described here: https://www.w3.org/TR/webauthn-2/#client-data
    /// @param clientChallenge This is the challenge that was sent to the client to sign. It is
    ///                        part of the client data. In a classic non-EVM flow, this challenge
    ///                        is generated by the server and sent to the client to avoid replay
    ///                        attack. In our context, as we already have the nonce for this purpose
    ///                        we use this field to pass the arbitrary execution order.
    ///                        This value is expected to not be encoded in Base64, the encoding is done
    ///                        during the verification.
    /// @return message The signature message needed to recover
    /// @dev 1. The signature counter is not checked in this implementation because
    ///         we already have the nonce on-chain to prevent the anti-replay attack.
    ///         The counter is 4-bytes long and it is located at bytes 33 of the authenticator data.
    ///      2. The RP.ID is not checked in this implementation as it is impossible to generate
    ///         the same keys for different RP.IDs with a well formed authenticator. The hash of the id
    ///         is 32-bytes long and it is located at bytes 0 of the authenticator data.
    ///      3. The length of the authenticator data is not fixed. It is at least 37 bytes
    ///         (rpIdHash (32) + flags (1) + counter (4)) but it can be longer if there is an
    ///         attested credential data and/or some extensions data. As we do not consider
    ///         the counter in this implementation, we only require the authenticator data to be
    ///         at least 32 bytes long in order to save some calldata gas.
    ///      4. You may probably ask why we encode the challenge in base64 on-chain instead of
    ///         of sending it already encoded to save some gas. This library is opinionated and
    ///         it assumes that it is used in the context of Account Abstraction. In this context,
    ///         valuable informations required to proceed the transaction will be stored in the
    ///         challenge meaning we need the challenge in clear to use it later in the flow.
    ///         That's why we decided to add an extra encoding step during the validation.
    ///      5. It is assumed this is not the responsibility of this contract to check the value
    ///         of the `alg` parameter. It is expected this contract will be extended by another
    ///         contract that will redirect the message produced by this contract to the right
    ///         recovery function.
    ///      6. Both extension data and attested credential data are out of scope of this implementation.
    ///      7. It is not the responsibility of this contract to validate the attestation statement formats
    ///
    ///         This contract is based on the level 2 of the WebAuthn specification.
    ///         and until proven otherwise compliant with the level 3 of the specification.
    function generateMessage(
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge
    )
        internal
        pure
        returns (bytes32 message)
    {
        unchecked {
            // Let the caller check the value of the flag in the authenticator data
            // @dev: we don't need to manually check the length of the authenticator data
            //       here as the EVM will automatically revert if the length is lower than 32
            if ((authenticatorData[32] & UV_FLAG_MASK) == 0) {
                revert InvalidAuthenticatorData();
            }

            // Ensure the client challenge is not null
            if (clientChallenge.length == 0) revert InvalidChallenge();

            // Encode the client challenge in base64 and explicitly convert it to bytes
            bytes memory challengeEncoded = bytes(Base64.encode(clientChallenge, true, true));

            // Extract the challenge from the client data and hash it
            // @dev: we don't need to check the overflow here as the EVM will automatically revert if
            //       `CLIENT_CHALLENGE_OFFSET + challengeEncoded.length` overflow. This is because we will
            //       try to access a chunk of memory by passing an end index lower than the start index
            bytes32 challengeHashed =
                keccak256(clientData[CLIENT_CHALLENGE_OFFSET:(CLIENT_CHALLENGE_OFFSET + challengeEncoded.length)]);

            // Hash the encoded challenge and check both challenges are equal
            if (keccak256(challengeEncoded) != challengeHashed) {
                revert InvalidClientData();
            }

            // Craft the signature message by hashing the client data, then concatenating
            // it to the authenticator data without padding, before hashing the result
            message = sha256(abi.encodePacked(authenticatorData, sha256(clientData)));
        }
    }

    /// @notice Verify ECDSA signature though WebAuthn on the secp256r1 curve
    function verify(
        bytes calldata authData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        internal
        returns (bool)
    {
        unchecked {
            bytes32 message = generateMessage(authData, clientData, clientChallenge);

            return ECDSA256r1.verify(message, r, s, qx, qy);
        }
    }
}
