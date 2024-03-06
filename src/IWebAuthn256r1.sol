// SPDX-License-Identifier: Apache-2.0
pragma solidity >=0.8.19 <0.9.0;

interface IWebAuthn256r1 {
    function verify(
        bytes1 authenticatorDataFlagMask,
        bytes calldata authenticatorData,
        bytes calldata clientData,
        bytes calldata clientChallenge,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        external
        returns (bool);
}
