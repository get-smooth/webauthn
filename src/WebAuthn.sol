// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import { Base64 } from "../lib/solady/src/utils/Base64.sol";
import { ECDSA256r1 } from "../lib/secp256r1-verify/src/ECDSA256r1.sol";

error InvalidAuthenticatorData();
error InvalidClientData();
error InvalidSignature();

library WebAuthn {
    function format(
        bytes calldata authenticatorData,
        bytes1 authenticatorDataFlagMask,
        bytes calldata clientData,
        bytes32 clientChallenge,
        uint256 clientChallengeOffset
    )
        internal
        pure
        returns (bytes32 result)
    {
        // Let the caller check if User Presence (0x01) or User Verification (0x04) are set
        {
            if ((authenticatorData[32] & authenticatorDataFlagMask) != authenticatorDataFlagMask) {
                revert InvalidAuthenticatorData();
            }
            // Verify that clientData commits to the expected client challenge
            string memory challengeEncoded = Base64.encode(abi.encodePacked(clientChallenge));
            bytes memory challengeExtracted = new bytes(
                bytes(challengeEncoded).length
            );

            assembly {
                calldatacopy( // copy from calldata to memory
                    add(challengeExtracted, 32), // destOffset
                    add(clientData.offset, clientChallengeOffset), // offset
                    mload(challengeExtracted) // size
                )
            }

            bytes32 moreData; //=keccak256(abi.encodePacked(challengeExtracted));
            assembly {
                moreData := keccak256(add(challengeExtracted, 32), mload(challengeExtracted))
            }
            if (keccak256(abi.encodePacked(bytes(challengeEncoded))) != moreData) {
                revert InvalidClientData();
            }
        }

        // Verify the signature over sha256(authenticatorData || sha256(clientData))
        bytes memory verifyData = new bytes(authenticatorData.length + 32);
        assembly {
            calldatacopy( // copy from calldata to memory
                add(verifyData, 32), // destOffset
                authenticatorData.offset, // offset
                authenticatorData.length // size
            )
        }
        bytes32 more = sha256(clientData);
        assembly {
            mstore(add(verifyData, add(authenticatorData.length, 32)), more)
        }

        return sha256(verifyData);
    }

    /// note: this implementation assumes the caller check if User Presence (0x01) or User Verification (0x04) are set
    function verify(
        bytes calldata authenticatorData,
        bytes1 authenticatorDataFlagMask,
        bytes calldata clientData,
        bytes32 clientChallenge,
        uint256 clientChallengeOffset,
        uint256 r,
        uint256 s,
        uint256 qx,
        uint256 qy
    )
        internal
        returns (bool)
    {
        bytes32 message =
            format(authenticatorData, authenticatorDataFlagMask, clientData, clientChallenge, clientChallengeOffset);

        return ECDSA256r1.verify(message, r, s, qx, qy);
    }
}
