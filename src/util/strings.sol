// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

library Strings {
    function len (string memory self) internal pure returns (uint256) {
        uint256 _len;
        uint256 i = 0;
        uint256 bytelength = bytes(self).length;
        for (_len = 0; i < bytelength; _len++) {
            bytes1 b = bytes(self)[i];
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return _len;
    }

    function charAt (
        string memory self,
        uint index
    ) internal pure returns (string memory char) {
        uint256 _len;
        uint256 i = 0;
        uint256 bytelength = bytes(self).length;
        for (_len = 0; i < bytelength; _len++) {
            bytes1 b = bytes(self)[i];
            uint i_0 = i;
            if (b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
            if (_len == index) {
                bytes memory charBytes = new bytes(i - i_0);
                for (uint x = 0; x < charBytes.length; x++) {
                    charBytes[x] = bytes(self)[i_0 + x];
                }
                return string(charBytes);
            }
        }
    }

    function eq(
        string memory self,
        string memory b
    ) internal pure returns (bool) {
        return (
            keccak256(abi.encodePacked((self))) == keccak256(abi.encodePacked((b)))
        );
    }

    function isNumber(
        string memory self
    ) internal pure returns (bool) {
        return Strings.eq(self, '0') ||
               Strings.eq(self, '1') ||
               Strings.eq(self, '2') ||
               Strings.eq(self, '3') ||
               Strings.eq(self, '4') ||
               Strings.eq(self, '5') ||
               Strings.eq(self, '6') ||
               Strings.eq(self, '7') ||
               Strings.eq(self, '8') ||
               Strings.eq(self, '9');
    }
}
