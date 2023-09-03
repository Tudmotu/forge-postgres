// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Vm } from 'forge-std/Vm.sol';
import { console2 } from 'forge-std/Test.sol';
import { DBType } from './DBType.sol';
import { Statement, StatementLib } from './Statement.sol';
import { Strings } from './util/strings.sol';

struct Record {
    string[] raw;
}

library RecordLib {
    using Strings for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function readString (
        Record memory self,
        uint columnIndex
    ) internal pure returns (string memory) {
        return self.raw[columnIndex];
    }

    function readBytes (
        Record memory self,
        uint columnIndex
    ) internal pure returns (bytes memory) {
        return vm.parseBytes(self.raw[columnIndex].beyond('\\x'));
    }

    function readAddress (
        Record memory self,
        uint columnIndex
    ) internal pure returns (address) {
        string memory value = self.raw[columnIndex];
        if (value.contains('\\')) {
            return address(bytes20(vm.parseBytes(value.beyond('\\x'))));
        }
        return vm.parseAddress(value);
    }

    function readUint (
        Record memory self,
        uint columnIndex
    ) internal pure returns (uint) {
        return vm.parseUint(self.raw[columnIndex]);
    }

    function readInt (
        Record memory self,
        uint columnIndex
    ) internal pure returns (int) {
        return vm.parseInt(self.raw[columnIndex]);
    }

    function readBytes32 (
        Record memory self,
        uint columnIndex
    ) internal pure returns (bytes32) {
        return vm.parseBytes32(self.raw[columnIndex].beyond('\\x'));
    }

    function readBool (
        Record memory self,
        uint columnIndex
    ) internal pure returns (bool) {
        return self.raw[columnIndex].eq('t');
    }
}

using RecordLib for Record global;
