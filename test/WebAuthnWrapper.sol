// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { WebAuthn256r1 } from "src/WebAuthn256r1.sol";
import { IWebAuthn256r1 } from "src/IWebAuthn256r1.sol";

/// @title WebAuthnWrapper
/// @notice This minimalist contract wraps the WebAuthn library for test/script purposes
contract WebAuthnWrapper is IWebAuthn256r1 {
    function _generateMessage(
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge
    )
        external
        pure
        returns (bytes32)
    {
        return WebAuthn256r1.generateMessage(authenticatorData, clientData, clientChallenge);
    }

    function verify(
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        external
        returns (bool)
    {
        return WebAuthn256r1.verify(authenticatorData, clientData, clientChallenge, r, s, qx, qy);
    }
}
