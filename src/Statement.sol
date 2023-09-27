// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import { Vm } from 'forge-std/Vm.sol';
import { DBType } from './DBType.sol';
import './util/strings.sol';

struct Statement {
    string query;
    DBType[] types;
    string[] values;
}

library StatementLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function from (
        string memory query
    ) public pure returns (Statement memory statement) {
        DBType[] memory types = new DBType[](0);
        string[] memory values = new string[](0);
        statement = Statement(query, types, values);
    }

    function addParam (
        Statement memory self,
        DBType dbType,
        string memory value
    ) internal pure {
        DBType[] memory newTypes = new DBType[](self.types.length + 1);
        string[] memory newValues = new string[](self.values.length + 1);

        for (uint i = 0; i < self.types.length; i++) {
            newTypes[i] = self.types[i];
        }
        newTypes[newTypes.length - 1] = dbType;
        self.types = newTypes;

        for (uint i = 0; i < self.values.length; i++) {
            newValues[i] = self.values[i];
        }
        newValues[newValues.length - 1] = value;
        self.values = newValues;
    }

    function addParam (
        Statement memory self,
        int64 value
    ) internal pure {
        self.addBigIntParam(value);
    }

    function addParam (
        Statement memory self,
        uint value
    ) internal pure {
        self.addDecimalParam(value);
    }

    function addParam (
        Statement memory self,
        string memory value
    ) internal pure {
        self.addTextParam(value);
    }

    function addParam (
        Statement memory self,
        address value
    ) internal pure {
        self.addByteaParam(value);
    }

    function addParam (
        Statement memory self,
        bool value
    ) internal pure {
        self.addBooleanParam(value);
    }

    function addParam (
        Statement memory self,
        bytes memory value
    ) internal pure {
        self.addByteaParam(value);
    }

    function addParam (
        Statement memory self,
        bytes32 value
    ) internal pure {
        self.addByteaParam(abi.encode(value));
    }

    function addBigIntParam (
        Statement memory self,
        int64 value
    ) internal pure {
        self.addParam(DBType.BIGINT, vm.toString(value));
    }

    function addDecimalParam (
        Statement memory self,
        uint value
    ) internal pure {
        self.addParam(DBType.DECIMAL, vm.toString(value));
    }

    function addIntParam (
        Statement memory self,
        int32 value
    ) internal pure {
        self.addParam(DBType.INT, vm.toString(value));
    }

    function addTextParam (
        Statement memory self,
        string memory value
    ) internal pure {
        self.addParam(DBType.TEXT, value);
    }

    function addByteaParam (
        Statement memory self,
        bytes memory value
    ) internal pure {
        self.addParam(DBType.BYTEA, vm.toString(value));
    }

    function addByteaParam (
        Statement memory self,
        address value
    ) internal pure {
        self.addParam(DBType.BYTEA, vm.toString(value));
    }

    function addBooleanParam (
        Statement memory self,
        bool value
    ) internal pure {
        self.addParam(DBType.BOOLEAN, vm.toString(value));
    }

    function prepare (
        Statement memory self
    ) internal returns (string memory statement) {
        if (self.types.length == 0) return self.query;
        string[] memory replacements = new string[](self.types.length);
        for (uint i = 0; i < self.types.length; i++) {
            string memory serialized = self.types[i].serialize(self.values[i]);
            replacements[i] = string.concat(
                "s/\\$", vm.toString(i+1), '/', serialized, "/g"
            );
        }

        string memory tmpFile = string.concat(
            vm.projectRoot(), '/.forge/tmp/fp.tmp.sql'
        );
        vm.writeFile(tmpFile, self.query);
        string[] memory args = new string[](3 + 2 * replacements.length);
        args[0] = 'sed';
        args[1] = '-i';
        args[args.length - 1] = tmpFile;

        for (uint i = 0; i < replacements.length; i++) {
            args[2 + 2 * i] = '-e';
            args[3 + 2 * i] = replacements[i];
        }

        vm.ffi(args);
        statement = vm.readFile(tmpFile);
    }
}

using StatementLib for Statement global;
