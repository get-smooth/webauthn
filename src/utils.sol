// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

// Those are bit masks that can be used to validate the flag in the
// authenticator data. The flag is located at byte 32 of the authenticator
// data and is used to indicate, among other things, wheter the user's
// presence/verification ceremonies have been performed.
// This version of the library is opinionated for passkeys that enforce UV.
//
// Here are some flags you may want to use depending on your needs.
// - 0x01: User presence (UP) is required. If the UP flag is not set, revert
// - 0x04: User verification (UV) is required. If the UV flag is not set, revert
// - 0x05: UV and UP are both accepted. If none of them is set, revert
//
// Read more about UP here: https://www.w3.org/TR/webauthn-2/#test-of-user-presence
// Read more about UV here: https://www.w3.org/TR/webauthn-2/#user-verification
bytes1 constant UP_FLAG_MASK = 0x01;
bytes1 constant UV_FLAG_MASK = 0x04;
bytes1 constant BOTH_FLAG_MASK = 0x05;

// The challenge is stored in the client data field of the WebAuthn response.
// The client data is a JSON object that contains a type, the challenge and the origin.
// For passkeys, the type is always "webauthn.get" or "webauthn.create".
// Ex: `{"type":"webauthn.create","challenge":<challenge>,"origin":"<origin>"}`
// Ex: `{"type":"webauthn.get","challenge":<challenge>,"origin":"<origin>"}`
//
// The client data always starts with a constant value which is the same for both
// the get and create flows. This constant value correspond to the beginning of
// the JSON object which is: `{"type":"webauthn.`. The next byte allow to distinguish
// between the get and create flows. It is either `g` (0x67) for get or `c` (0x63) for create.
// The three constants located below can be used to know if a WebAuthn response is a get or create flow.
uint256 constant OFFSET_CLIENT_TYPE = 0x12;
bytes1 constant TYPE_GET_INDICATOR = 0x67;
bytes1 constant TYPE_CREATE_INDICATOR = 0x63;
// The offset of the client challenge for the get flow
// Correspond to the constant value `{"type":"webauthn.get","challenge":`
uint256 constant OFFSET_CLIENT_CHALLENGE_GET = 0x24;
// The offset of the client challenge for the create flow
// Correspond to the constant value `{"type":"webauthn.create","challenge":`
uint256 constant OFFSET_CLIENT_CHALLENGE_CREATE = 0x27;
// The offset where the credential ID length starts and its length
uint256 constant OFFSET_CREDID_LENGTH = 0x35; // 53
uint256 constant CREDID_LENGTH_LENGTH = 0x02;
// The offset where the credential ID value starts
uint256 constant OFFSET_CREDID = 0x37; // 55
// The offset of the flag mask
uint256 constant OFFSET_FLAG = 0x20; // 32
// The length of the public key coordinates
uint256 constant P256R1_PUBKEY_COORD_LENGTH = 0x20; // 32
