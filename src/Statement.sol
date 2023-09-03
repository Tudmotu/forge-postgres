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
    uint paramCount;
}

library StatementLib {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    function from (
        string memory query
    ) public pure returns (Statement memory statement) {
        uint varCount = StatementLib._findVarCount(query);
        DBType[] memory types = new DBType[](varCount);
        string[] memory values = new string[](varCount);
        statement = Statement(query, types, values, 0);
    }

    function _findVarCount (
        string memory query
    ) internal pure returns (uint count) {
        uint c = 0;
        while (c < Strings.len(query)) {
            string memory char = Strings.charAt(query, c);
            if (Strings.eq(char, '\\')) {
                c += 2;
            }
            else if (Strings.eq(char, '$')) {
                string memory number = '';
                uint n = 1;
                while (Strings.isNumber(Strings.charAt(query, c + n))) {
                    number = string.concat(number, Strings.charAt(query, c + n));
                    n++;
                }
                uint varIndex = vm.parseUint(number);
                if (varIndex > count) count = varIndex;
                c += n;
            }
            else {
                c++;
            }
        }
    }

    function addParam (
        Statement memory self,
        DBType dbType,
        string memory value
    ) internal pure {
        self.types[self.paramCount] = dbType;
        self.values[self.paramCount] = value;
        self.paramCount++;
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
    ) internal pure returns (string memory statement) {
        uint c = 0;
        while (c < Strings.len(self.query)) {
            string memory char = Strings.charAt(self.query, c);
            if (Strings.eq(char, '\\')) {
                statement = string.concat(
                    statement,
                    char,
                    Strings.charAt(self.query, c + 1)
                );
                c += 2;
            }
            else if (Strings.eq(char, '$')) {
                string memory number = '';
                uint n = 1;
                while (Strings.isNumber(Strings.charAt(self.query, c + n))) {
                    number = string.concat(number, Strings.charAt(self.query, c + n));
                    n++;
                }
                uint varIndex = vm.parseUint(number) - 1;
                string memory val = self.types[varIndex]
                                        .serialize(self.values[varIndex]);
                statement = string.concat(statement, val);
                c += n;
            }
            else {
                statement = string.concat(statement, char);
                c++;
            }
        }
    }
}

using StatementLib for Statement global;
