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

// The offset of the client challenge in the client data
uint256 constant OFFSET_CLIENT_CHALLENGE = 0x24;
// The offset where the credential ID length starts and its length
uint256 constant OFFSET_CREDID_LENGTH = 0x35; // 53
uint256 constant CREDID_LENGTH_LENGTH = 0x02;
// The offset where the credential ID value starts
uint256 constant OFFSET_CREDID = 0x37; // 55
// The offset of the flag mask
uint256 constant OFFSET_FLAG = 0x20; // 32

uint256 constant P256R1_PUBKEY_COORD_LENGTH = 0x20; // 32
