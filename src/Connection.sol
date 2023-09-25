// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Vm } from 'forge-std/Vm.sol';
import { console2 } from 'forge-std/Test.sol';
import { DBType } from './DBType.sol';
import { Statement, StatementLib } from './Statement.sol';
import { Record } from './Record.sol';
import { Strings } from './util/strings.sol';

struct Connection {
    string username;
    string passwd;
    string host;
    string database;
}

library ConnectionLib {
    using Strings for string;

    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    string private constant SEP = unicode'󿿽'; // Special unused unicode character as separator

    function connURL (Connection memory self) internal pure returns (string memory url) {
        url = string.concat(
            "postgres://",
            self.username,
            ":",
            self.passwd,
            "@",
            self.host,
            "/",
            self.database
        );
    }

    function _execute (
        Connection memory self,
        Statement memory statement
    ) internal returns (Record[] memory records) {
        string[] memory psqlInputs = new string[](10);
        psqlInputs[0] = 'psql';
        psqlInputs[1] = self.connURL();
        psqlInputs[2] = string.concat('-F', SEP);
        psqlInputs[3] = '-A';
        psqlInputs[4] = '-t';
        psqlInputs[5] = '-c';
        psqlInputs[6] = "select 'forge-postgres'";
        psqlInputs[7] = '-c';
        psqlInputs[8] = statement.prepare();
        bytes memory res = vm.ffi(psqlInputs);
        string[] memory lines = string(res).split('\n');
        if (lines.length == 0) {
            return records;
        }
        records = new Record[](lines.length - 1);

        for (uint i = 1; i < lines.length; i++) {
            string memory line = lines[i];
            string[] memory splits = line.split(SEP);

            if (splits.length == 0) {
                splits = new string[](1);
                splits[0] = line;
            }

            records[i - 1] = Record(splits);
        }
    }

    function execute (
        Connection memory self,
        string memory query
    ) public returns (Record[] memory data) {
        data = self._execute(StatementLib.from(query));
    }

    function execute (
        Connection memory self,
        Statement memory statement
    ) public returns (Record[] memory data) {
        data = self._execute(statement);
    }

    function createStatement (
        Connection memory self,
        string memory query
    ) public pure returns (Statement memory) {
        self;
        return StatementLib.from(query);
    }
}

using ConnectionLib for Connection global;
